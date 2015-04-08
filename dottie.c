/*
 * dottie.c - Dot Files Manager
 * Copyright (c) 2015 Arkadiusz Bokowy
 *
 * This projected is licensed under the terms of the MIT license.
 *
 * Compilation:
 * gcc -o dottie dottie.c
 *
 * Requirements:
 * Coreutils version >= 8.16 is required (version >= 8.22 is recommended due
 * to bug in the ln tool).
 *
 * Synopsis:
 *
 * There is a lot of config file (aka dotfile) managing tools and approaches
 * on the market already. Unfortunately none of them is centered on one job
 * and one job only - managing them. Since, this task could be achieved in a
 * few lines of script, why not to make it in a more efficient and cool way -
 * a small tool written in C.
 *
 * This small tool takes its philosophy from the git itself (coupled usage is
 * recommended). For the managing purpose one does not have to use any other
 * command than dottie - e.g. adding files to the bucket and later sync. There
 * are three available ways of synchronization: copying, symbolic linking and
 * hard linking. For the EXT-based file systems symlink is recommended.
 *
 * Exemplary usage:
 *
 *   $ mkdir -p /mnt/backups/dotfiles/ && cd $_
 *   $ dottie init          # initialize bucket
 *   $ dottie add ~/.vimrc  # add or update file
 *   $ dottie               # show status
 *   $ dottie -s sync       # create links
 *
 */

#define _GNU_SOURCE
#include <errno.h>
#include <fcntl.h>
#include <ftw.h>
#include <getopt.h>
#include <libgen.h>
#include <pwd.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/wait.h>


/* list of available commands */
enum dottie_command {
	DOTTIE_COMMAND_STATUS = 0,
	DOTTIE_COMMAND_INIT,
	DOTTIE_COMMAND_SYNC,
	DOTTIE_COMMAND_ADD,
};

/* list of available sync actions */
enum sync_action {
	SYNC_ACTION_COPY = 0,
	SYNC_ACTION_SYMBOLIC,
	SYNC_ACTION_HARDLINK,
};

/* list of available sync statuses */
enum sync_status {
	SYNC_STATUS_MISSING = 0,
	SYNC_STATUS_SYNCED,
	SYNC_STATUS_SYMBOLIC,
	SYNC_STATUS_HARDLINK,
	SYNC_STATUS_DIRECTORY,
	SYNC_STATUS_DIVERGED,
};

/* dottie executable name */
static const char *dottie;

/* selected dottie command */
static enum dottie_command dottie_command;

/* selected synchronization action */
static enum sync_action dottie_action;

/* force dottie action - never prompt */
static int dottie_force = 0;

/* user home directory - relative path for dot files */
static char *user_homedir;

/* dottie anchor extension */
static char *dottie_extension;


/* Windows-based function for spawning child processes. On success, the PID
 * of the child process is returned. On error, -1 is returned, and errno is
 * set appropriately. */
static int spawnlp(const char *file, const char *arg, ...) {

	pid_t pid = fork();
	if (pid != 0)
		return pid;

	va_list ap;
	char **argv;
	int n;

	va_start(ap, arg);
	n = 1;
	while (va_arg(ap, char *) != NULL)
		n++;
	va_end(ap);

	if ((argv = alloca((n + 1) * sizeof(*argv))) == NULL)
		abort();

	va_start(ap, arg);
	n = 1;
	argv[0] = (char *)arg;
	while ((argv[n] = va_arg(ap, char *)) != NULL)
		n++;
	va_end(ap);

	execvp(file, argv);
	perror("spawn: execvp");
	abort();
}

/* Use UNIX mkdir utility in order to recursively create directory component
 * of the destination path. */
static void unix_mkdir(const char *dst) {

	char *tmp = strdup(dst);
	char *dir = dirname(tmp);

	if (strcmp(dir, ".") != 0 && strcmp(dir, "/") != 0) {
		spawnlp("mkdir", "mkdir", "-p", dir, (char *)NULL);
		wait(NULL);
	}
	free(tmp);
}

/* Use UNIX rm utility in order to recursively remove destination path. */
static void unix_unlink(const char *dst) {
	spawnlp("rm", "rm", "-rf", dst, (char *)NULL);
	wait(NULL);
}

/* Use UNIX cp utility in order to recursively copy source path into the
 * destination one. If force is non-zero, then interactive copy is done. */
static void unix_copy(const char *src, const char *dst, int force) {

	if (force)
		unix_unlink(dst);

	unix_mkdir(dst);

	spawnlp("cp", "cp", "-aTi", src, dst, (char *)NULL);
	wait(NULL);
}

/* Use UNIX ln utility in order to create symbolic link. If force is non-zero,
 * then interactive linking is done. */
static void unix_symlink(const char *src, const char *dst, int force) {

	if (force)
		unix_unlink(dst);

	unix_mkdir(dst);

	spawnlp("ln", "ln", "-srTi", src, dst, (char *)NULL);
	wait(NULL);
}

/* Use UNIX ln utility in order to create hard link. If force is non-zero,
 * then interactive linking is done. */
static void unix_link(const char *src, const char *dst, int force) {

	if (force)
		unix_unlink(dst);

	unix_mkdir(dst);

	spawnlp("ln", "ln", "-PTi", src, dst, (char *)NULL);
	wait(NULL);
}

/* Callback function for the nftw (file tree walk). Since it is not possible
 * to pass user defined pointer to this callback, all settings are passed via
 * global variables, which means, that this function is not thread-safe. */
static int traverse(const char *fpath, const struct stat *sb, int typeflag,
		struct FTW *ftwbuf) {

	const int fpath_base_length = strlen(&fpath[ftwbuf->base]);
	const int dottie_ext_length = strlen(dottie_extension);

	/* discard fpath without the dottie extension */
	if (fpath_base_length <= dottie_ext_length || strcmp(fpath + ftwbuf->base +
				fpath_base_length - dottie_ext_length, dottie_extension) != 0)
		return FTW_CONTINUE;

	enum sync_status status;
	struct stat sb_dest;
	char *fpath_dest;

	/* build destination path - one relative to the user home directory */
	if (asprintf(&fpath_dest, "%s/%s", user_homedir, &fpath[2]) == -1) {
		perror("error: build destination path");
		return FTW_CONTINUE;
	}
	fpath_dest[strlen(fpath_dest) - dottie_ext_length] = '\0';

	/* check current synchronization status */
	if (lstat(fpath_dest, &sb_dest) == 0) {
		const int islink = S_ISLNK(sb_dest.st_mode);
		if (islink)
			stat(fpath_dest, &sb_dest);
		if (sb->st_ino == sb_dest.st_ino) {
			if (islink)
				status = SYNC_STATUS_SYMBOLIC;
			else
				status = SYNC_STATUS_HARDLINK;
		}
		else {
			if (sb->st_mtime == sb_dest.st_mtime && sb->st_size == sb_dest.st_size &&
					sb->st_mode == sb_dest.st_mode && sb->st_uid == sb_dest.st_uid &&
					sb->st_gid == sb_dest.st_gid) {
				if (typeflag == FTW_D)
					status = SYNC_STATUS_DIRECTORY;
				else
					status = SYNC_STATUS_SYNCED;
			}
			else
				status = SYNC_STATUS_DIVERGED;
		}
	}
	else {
		status = SYNC_STATUS_MISSING;
		if (errno != ENOENT)
			perror("warning: stat destination path");
	}

	/* display current status information */
	if (dottie_command == DOTTIE_COMMAND_STATUS)
		switch (status) {
		case SYNC_STATUS_MISSING:
			printf("[  ] %s\n", &fpath[2]);
			break;
		case SYNC_STATUS_SYNCED:
			printf("[==] %s :: %s\n", &fpath[2], fpath_dest);
			break;
		case SYNC_STATUS_SYMBOLIC:
			printf("[->] %s :: %s\n", &fpath[2], fpath_dest);
			break;
		case SYNC_STATUS_HARDLINK:
			printf("[=>] %s :: %s\n", &fpath[2], fpath_dest);
			break;
		case SYNC_STATUS_DIRECTORY:
			printf("(==) %s :: %s\n", &fpath[2], fpath_dest);
			break;
		case SYNC_STATUS_DIVERGED:
			printf("[!=] %s :: %s\n", &fpath[2], fpath_dest);
			break;
		}

	/* synchronize configuration with user home directory */
	if (dottie_command == DOTTIE_COMMAND_SYNC) {
		switch (dottie_action) {
		case SYNC_ACTION_COPY:
			unix_copy(fpath, fpath_dest, dottie_force);
			break;
		case SYNC_ACTION_SYMBOLIC:
			if (status != SYNC_STATUS_SYMBOLIC)
				unix_symlink(fpath, fpath_dest, dottie_force);
			break;
		case SYNC_ACTION_HARDLINK:
			if (status != SYNC_STATUS_HARDLINK)
				unix_link(fpath, fpath_dest, dottie_force);
			break;
		}
	}

	free(fpath_dest);
	if (typeflag == FTW_D)
		return FTW_SKIP_SUBTREE;
	return FTW_CONTINUE;
}

/* Add a new path to the dottie file bucket. On success, this function
 * returns 0, otherwise -1.*/
static int dottie_command_add(int argc, char *path[]) {

	/* this command requires extra argument - show usage if missing */
	if (argc == 0) {
		fprintf(stderr, "usage: %s [options] add <path>...\n", dottie);
		return -1;
	}

	char *path_real;
	int homedir_length;
	int i;

	homedir_length = strlen(user_homedir);
	for (i = 0; i < argc; i++) {

		if ((path_real = realpath(path[i], NULL)) == NULL) {
			fprintf(stderr, "%s: add path: %s\n", dottie, path[i]);
			perror("error:");
			continue;
		}

		/* check if given path lays in the user home directory */
		if (strstr(path_real, user_homedir) != path_real) {
			fprintf(stderr, "%s: add path: %s\n", dottie, path_real);
			fprintf(stderr, "error: only home directory is allowed\n");
		}
		else {

			char *path_dest;
			int n = homedir_length;
			if (path_real[n] == '/')
				n++;

			if (asprintf(&path_dest, "%s%s", &path_real[n], dottie_extension) == -1)
				perror("error: build destination path");
			else {
				unix_copy(path_real, path_dest, dottie_force);
				free(path_dest);
			}
		}

		free(path_real);
	}

	return 0;
}

/* Initialize dottie file bucket in the current directory. On success, this
 * function returns 0, otherwise -1. */
static int dottie_command_init(void) {

	if (access(dottie_extension, F_OK) == 0)
		return 0;

	int fd;

	if ((fd = creat(dottie_extension, 00644)) == -1) {
		perror("warning: create dottie file");
		return -1;
	}

	dprintf(fd, "Unnamed dottie file bucket.\n");
	return close(fd);
}

int main(int argc, char *argv[]) {

	int opt;
	const char *opts = "hcslfE:";
	struct option longopts[] = {
		{ "help", no_argument, NULL, 'h' },
		{ "copy", no_argument, NULL, 'c' },
		{ "symbolic", no_argument, NULL, 's' },
		{ "hardlink", no_argument, NULL, 'l' },
		{ "force", no_argument, NULL, 'f' },
		/* redefine build-in dottie extension */
		{ "dot-ext", required_argument, NULL, 'E' },
		{ 0, 0, 0, 0 },
	};
	struct command {
		const char *name;
		enum dottie_command cmd;
	} cmds[] = {
		{ "add", DOTTIE_COMMAND_ADD },
		{ "init", DOTTIE_COMMAND_INIT },
		{ "status", DOTTIE_COMMAND_STATUS },
		{ "sync", DOTTIE_COMMAND_SYNC },
		{ 0, 0 },
	};

	/* set-up default configuration */
	dottie_extension = strdup(".dottie");
	dottie_action = SYNC_ACTION_COPY;
	dottie = argv[0];

	while ((opt = getopt_long(argc, argv, opts, longopts, NULL)) != -1)
		switch (opt) {
		case 'h':
return_usage:
			printf("usage: %s [options] [<command>] [<args>]\n"
					"\noptions:\n"
					"  -c, --copy\t\tuse copy for sync action (default)\n"
					"  -s, --symbolic\tuse symbolic link for sync action\n"
					"  -l, --hardlink\tuse hard link for sync action\n"
					"  -f, --force\t\toverwrite existing files, never prompt\n"
					"\ncommands:\n"
					"  add\t\tadd new path to the bucket\n"
					"  init\t\tinitialize dottie bucket\n"
					"  status\tshow synchronization status\n"
					"  sync\t\tsynchronize bucket files\n"
					"\nstatus symbols:\n"
					"  [==] - synced\t\t[=>] - hard link\t[!=] - diverged\n"
					"  (==) - directory\t[->] - symbolic link\t[  ] - missing\n",
					dottie);
			return EXIT_SUCCESS;

		case 'c':
			dottie_action = SYNC_ACTION_COPY;
			break;

		case 's':
			dottie_action = SYNC_ACTION_SYMBOLIC;
			break;

		case 'l':
			dottie_action = SYNC_ACTION_HARDLINK;
			break;

		case 'f':
			dottie_force = 1;
			break;

		case 'E':
			free(dottie_extension);
			if (asprintf(&dottie_extension, ".%s", optarg) == -1) {
				perror("error: redefine dottie extension");
				return EXIT_FAILURE;
			}
			break;

		default:
			fprintf(stderr, "Try '%s --help' for more information.\n", dottie);
			return EXIT_FAILURE;
		}

	/* parse command line command argument */
	if (optind < argc) {
		int i;
		for (i = 0; cmds[i].name != NULL; i++)
			if (strcmp(argv[optind], cmds[i].name) == 0) {
				dottie_command = cmds[i].cmd;
				break;
			}
		if (cmds[i].name == NULL) {
			fprintf(stderr, "error: unrecognized command: %s\n", argv[optind]);
			return EXIT_FAILURE;
		}
		optind++;
	}
	else if (optind == argc)
		dottie_command = DOTTIE_COMMAND_STATUS;
	else
		goto return_usage;

	if (dottie_command == DOTTIE_COMMAND_INIT) {
		if (dottie_command_init() != 0)
			return EXIT_FAILURE;
		return EXIT_SUCCESS;
	}

	/* check if current directory is a dottie file bucket */
	if (access(dottie_extension, F_OK) != 0) {
		fprintf(stderr, "error: current directory is not a dottie bucket\n");
		return EXIT_FAILURE;
	}

	/* get current user home directory */
	if ((user_homedir = getenv("HOME")) == NULL)
		user_homedir = getpwuid(getuid())->pw_dir;

	if (dottie_command == DOTTIE_COMMAND_ADD) {
		if (dottie_command_add(argc - optind, &argv[optind]) != 0)
			return EXIT_FAILURE;
		return EXIT_SUCCESS;
	}

	/* traverse current directory without following symbolic links */
	if (nftw(".", traverse, 50, FTW_ACTIONRETVAL | FTW_MOUNT | FTW_PHYS) == -1) {
		perror("error: traverse current path");
		return EXIT_FAILURE;
	}

	return EXIT_SUCCESS;
}
