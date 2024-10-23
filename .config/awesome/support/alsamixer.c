/*
 * ALSA Mixer Library for LGI
 *
 * Copyright (c) 2024 Arkadiusz Bokowy
 *
 * Licensed under the terms of the MIT license.
 *
 */

#include "alsamixer.h"

#include <alsa/asoundlib.h>
#include <glib-object.h>
#include <glib.h>

/* AlsaMixer.Mixer */

struct _AlsaMixerMixer {
	GObject parent;
	GSource * source;
	snd_mixer_t * mixer;
};

G_DEFINE_TYPE(AlsaMixerMixer, alsa_mixer_mixer, G_TYPE_OBJECT)

static void alsa_mixer_mixer_finalize(GObject * object) {
	AlsaMixerMixer * self = ALSA_MIXER_MIXER(object);
	if (self->source != NULL) {
		g_source_destroy(self->source);
		g_source_unref(self->source);
	}
	if (self->mixer != NULL)
		snd_mixer_close(self->mixer);
	AlsaMixerMixerClass * cls = g_type_class_peek(ALSA_MIXER_TYPE_MIXER);
	G_OBJECT_CLASS(g_type_class_peek_parent(cls))->finalize(object);
}

static void alsa_mixer_mixer_class_init(AlsaMixerMixerClass * cls) {
	GObjectClass * obj_cls = G_OBJECT_CLASS(cls);
	obj_cls->finalize = alsa_mixer_mixer_finalize;
}

static void alsa_mixer_mixer_init(G_GNUC_UNUSED AlsaMixerMixer * self) {}

/* AlsaMixer.Element */

struct _AlsaMixerElement {
	GObject parent;
	snd_mixer_elem_t * elem;
};

G_DEFINE_TYPE(AlsaMixerElement, alsa_mixer_element, G_TYPE_OBJECT)

typedef enum {
	ELEM_PROP_NAME = 1,
	ELEM_PROP_INDEX,
	ELEM_PROP_ACTIVE,
	ELEM_PROP_PLAYBACK,
	ELEM_PROP_PLAYBACK_DB,
	ELEM_PROP_PLAYBACK_DB_MIN,
	ELEM_PROP_PLAYBACK_DB_MAX,
	ELEM_PROP_PLAYBACK_RAW,
	ELEM_PROP_PLAYBACK_RAW_MIN,
	ELEM_PROP_PLAYBACK_RAW_MAX,
	ELEM_PROP_PLAYBACK_SWITCH,
	ELEM_N_PROPERTIES,
} AlsaMixerElementProperty;

static GParamSpec * elem_props[ELEM_N_PROPERTIES];

static void alsa_mixer_element_set_property(GObject * object, guint prop_id, const GValue * value, GParamSpec * pspec) {
	AlsaMixerElement * element = ALSA_MIXER_ELEMENT(object);
	switch (prop_id) {
	case ELEM_PROP_PLAYBACK_DB:
		if (snd_mixer_selem_has_playback_volume(element->elem)) {
			long min = 0, max = 0;
			snd_mixer_selem_get_playback_dB_range(element->elem, &min, &max);
			const long v = g_value_get_float(value) * 100;
			snd_mixer_selem_set_playback_dB_all(element->elem, MIN(MAX(v, min), max), 0);
		}
		break;
	case ELEM_PROP_PLAYBACK_RAW:
		if (snd_mixer_selem_has_playback_volume(element->elem)) {
			long min = 0, max = 0;
			snd_mixer_selem_get_playback_volume_range(element->elem, &min, &max);
			const long v = MIN(MAX(g_value_get_long(value), min), max);
			snd_mixer_selem_set_playback_volume_all(element->elem, v);
		}
		break;
	case ELEM_PROP_PLAYBACK_SWITCH:
		if (snd_mixer_selem_has_playback_switch(element->elem)) {
			const int v = g_value_get_boolean(value);
			snd_mixer_selem_set_playback_switch_all(element->elem, v);
		}
		break;
	default:
		G_OBJECT_WARN_INVALID_PROPERTY_ID(object, prop_id, pspec);
		break;
	}
}

static int snd_mixer_selem_get_playback_dB_all(snd_mixer_elem_t * elem, long * value) {
	int channels = 0;
	long value_all = 0;
	/* Get average dB for all channels. */
	for (snd_mixer_selem_channel_id_t channel = 0; channel <= SND_MIXER_SCHN_LAST; channel++) {
		if (!snd_mixer_selem_has_playback_channel(elem, channel))
			continue;
		long tmp = 0;
		snd_mixer_selem_get_playback_dB(elem, channel, &tmp);
		channels += 1;
		value_all += tmp;
	}
	*value = value_all / channels;
	return 0;
}

static int snd_mixer_selem_get_playback_volume_all(snd_mixer_elem_t * elem, long * value) {
	int channels = 0;
	long value_all = 0;
	/* Get average volume for all channels. */
	for (snd_mixer_selem_channel_id_t channel = 0; channel <= SND_MIXER_SCHN_LAST; channel++) {
		if (!snd_mixer_selem_has_playback_channel(elem, channel))
			continue;
		long tmp = 0;
		snd_mixer_selem_get_playback_volume(elem, channel, &tmp);
		channels += 1;
		value_all += tmp;
	}
	*value = value_all / channels;
	return 0;
}

static void alsa_mixer_element_get_property(GObject * object, guint prop_id, GValue * value, GParamSpec * pspec) {
	AlsaMixerElement * element = ALSA_MIXER_ELEMENT(object);
	switch (prop_id) {
	case ELEM_PROP_NAME:
		g_value_set_string(value, snd_mixer_selem_get_name(element->elem));
		break;
	case ELEM_PROP_INDEX:
		g_value_set_uint(value, snd_mixer_selem_get_index(element->elem));
		break;
	case ELEM_PROP_ACTIVE:
		g_value_set_boolean(value, snd_mixer_selem_is_active(element->elem));
		break;
	case ELEM_PROP_PLAYBACK:
		g_value_set_boolean(value, snd_mixer_selem_has_playback_volume(element->elem));
		break;
	case ELEM_PROP_PLAYBACK_DB: {
		long tmp = 0;
		snd_mixer_selem_get_playback_dB_all(element->elem, &tmp);
		g_value_set_float(value, tmp / 100.0);
	} break;
	case ELEM_PROP_PLAYBACK_DB_MIN:
	case ELEM_PROP_PLAYBACK_DB_MAX: {
		long min = 0, max = 0;
		snd_mixer_selem_get_playback_dB_range(element->elem, &min, &max);
		g_value_set_float(value, (prop_id == ELEM_PROP_PLAYBACK_DB_MIN ? min : max) / 100.0);
	} break;
	case ELEM_PROP_PLAYBACK_RAW: {
		long tmp = 0;
		snd_mixer_selem_get_playback_volume_all(element->elem, &tmp);
		g_value_set_long(value, tmp);
	} break;
	case ELEM_PROP_PLAYBACK_RAW_MIN:
	case ELEM_PROP_PLAYBACK_RAW_MAX: {
		long min = 0, max = 0;
		snd_mixer_selem_get_playback_volume_range(element->elem, &min, &max);
		g_value_set_long(value, prop_id == ELEM_PROP_PLAYBACK_RAW_MIN ? min : max);
	} break;
	case ELEM_PROP_PLAYBACK_SWITCH: {
		int enabled = 0;
		/* Find at least one enabled channel. */
		for (snd_mixer_selem_channel_id_t channel = 0; channel <= SND_MIXER_SCHN_LAST; channel++) {
			if (!snd_mixer_selem_has_playback_channel(element->elem, channel))
				continue;
			int tmp = 0;
			snd_mixer_selem_get_playback_switch(element->elem, channel, &tmp);
			if (!tmp)
				continue;
			enabled = 1;
			break;
		}
		g_value_set_boolean(value, enabled);
	} break;
	default:
		G_OBJECT_WARN_INVALID_PROPERTY_ID(object, prop_id, pspec);
		break;
	}
}

static void alsa_mixer_element_finalize(GObject * object) {
	snd_mixer_elem_set_callback(ALSA_MIXER_ELEMENT(object)->elem, NULL);
	AlsaMixerElementClass * cls = g_type_class_peek(ALSA_MIXER_TYPE_ELEMENT);
	G_OBJECT_CLASS(g_type_class_peek_parent(cls))->finalize(object);
}

#define PARAM_BOOL(N, PERM) g_param_spec_boolean(N, NULL, NULL, FALSE, G_PARAM_##PERM);
#define PARAM_STRING(N, PERM) g_param_spec_string(N, NULL, NULL, NULL, G_PARAM_##PERM);
#define PARAM_UINT(N, PERM, MIN, MAX) g_param_spec_uint(N, NULL, NULL, MIN, MAX, 0, G_PARAM_##PERM);
#define PARAM_LONG(N, PERM, MIN, MAX) g_param_spec_long(N, NULL, NULL, MIN, MAX, 0, G_PARAM_##PERM);
#define PARAM_FLOAT(N, PERM, MIN, MAX) g_param_spec_float(N, NULL, NULL, MIN, MAX, 0, G_PARAM_##PERM);

static void alsa_mixer_element_class_init(G_GNUC_UNUSED AlsaMixerElementClass * cls) {

	elem_props[ELEM_PROP_NAME] = PARAM_STRING("name", READABLE);
	elem_props[ELEM_PROP_INDEX] = PARAM_UINT("index", READABLE, 0, 10);
	elem_props[ELEM_PROP_ACTIVE] = PARAM_BOOL("active", READABLE);
	elem_props[ELEM_PROP_PLAYBACK] = PARAM_BOOL("playback", READABLE);
	elem_props[ELEM_PROP_PLAYBACK_DB] = PARAM_FLOAT("playback-db", READWRITE, -120, 12);
	elem_props[ELEM_PROP_PLAYBACK_DB_MIN] = PARAM_FLOAT("playback-db-min", READABLE, -120, 12);
	elem_props[ELEM_PROP_PLAYBACK_DB_MAX] = PARAM_FLOAT("playback-db-max", READABLE, -120, 12);
	elem_props[ELEM_PROP_PLAYBACK_RAW] = PARAM_LONG("playback-raw", READWRITE, G_MINLONG, G_MAXLONG);
	elem_props[ELEM_PROP_PLAYBACK_RAW_MIN] = PARAM_LONG("playback-raw-min", READABLE, G_MINLONG, G_MAXLONG);
	elem_props[ELEM_PROP_PLAYBACK_RAW_MAX] = PARAM_LONG("playback-raw-max", READABLE, G_MINLONG, G_MAXLONG);
	elem_props[ELEM_PROP_PLAYBACK_SWITCH] = PARAM_BOOL("playback-switch", READWRITE);

	GObjectClass * object_cls = G_OBJECT_CLASS(cls);
	object_cls->set_property = alsa_mixer_element_set_property;
	object_cls->get_property = alsa_mixer_element_get_property;
	object_cls->finalize = alsa_mixer_element_finalize;
	g_object_class_install_properties(object_cls, G_N_ELEMENTS(elem_props), elem_props);
}

static void alsa_mixer_element_init(G_GNUC_UNUSED AlsaMixerElement * self) {}

static int alsa_mixer_element_callback(snd_mixer_elem_t * elem, G_GNUC_UNUSED unsigned int mask) {
	AlsaMixerElement * element = snd_mixer_elem_get_callback_private(elem);
	if (mask == SND_CTL_EVENT_MASK_REMOVE)
		element->elem = NULL;
	g_object_notify_by_pspec(G_OBJECT(element), elem_props[ELEM_PROP_NAME]);
	return 0;
}

static AlsaMixerElement * alsa_mixer_element_new(snd_mixer_elem_t * elem) {

	AlsaMixerElement * element = g_object_new(ALSA_MIXER_TYPE_ELEMENT, NULL);
	element->elem = elem;

	snd_mixer_elem_set_callback_private(elem, element);
	snd_mixer_elem_set_callback(elem, alsa_mixer_element_callback);

	return element;
}

/* ALSA mixer GLib source */

typedef struct {
	GSource source;
	snd_mixer_t * mixer;
} AlsaMixerSource;

static gboolean alsa_mixer_source_dispatch(GSource * source, G_GNUC_UNUSED GSourceFunc callback,
                                           G_GNUC_UNUSED void * userdata) {
	snd_mixer_handle_events(((AlsaMixerSource *)source)->mixer);
	return G_SOURCE_CONTINUE;
}

static GSourceFuncs alsa_mixer_source_funcs = {
	.dispatch = alsa_mixer_source_dispatch,
};

static GIOCondition events2condition(int events) {
	GIOCondition conditions = 0;
	if (events & POLLIN)
		conditions |= G_IO_IN;
	if (events & POLLOUT)
		conditions |= G_IO_OUT;
	if (events & POLLERR)
		conditions |= G_IO_ERR;
	if (events & POLLHUP)
		conditions |= G_IO_HUP;
	return conditions;
}

static GSource * alsa_mixer_source_new(AlsaMixerMixer * mixer) {

	GSource * source = g_source_new(&alsa_mixer_source_funcs, sizeof(AlsaMixerSource));
	((AlsaMixerSource *)source)->mixer = mixer->mixer;

	const int count = snd_mixer_poll_descriptors_count(mixer->mixer);
	struct pollfd pfds[16];

	g_assert(count <= (int)sizeof(pfds));
	g_assert(snd_mixer_poll_descriptors(mixer->mixer, pfds, count) == count);
	for (int i = 0; i < count; i++)
		g_source_add_unix_fd(source, pfds[i].fd, events2condition(pfds[i].events));

	return source;
}

/* Binding API */

AlsaMixerMixer * alsa_mixer_mixer_new(void) {

	snd_mixer_t * snd_mixer;
	if (snd_mixer_open(&snd_mixer, 0) != 0)
		return NULL;

	AlsaMixerMixer * mixer = g_object_new(ALSA_MIXER_TYPE_MIXER, NULL);
	mixer->mixer = snd_mixer;

	return mixer;
}

int alsa_mixer_mixer_attach(AlsaMixerMixer * self, const char * name) {

	int rv;
	if ((rv = snd_mixer_attach(self->mixer, name)) != 0)
		return rv;
	if ((rv = snd_mixer_load(self->mixer)) != 0)
		return rv;
	if ((rv = snd_mixer_selem_register(self->mixer, NULL, NULL)) != 0)
		return rv;

	self->source = alsa_mixer_source_new(self);
	g_source_attach(self->source, NULL);

	return 0;
}

int alsa_mixer_mixer_detach(AlsaMixerMixer * self, const char * name) {
	int rv;
	if ((rv = snd_mixer_detach(self->mixer, name)) != 0)
		return rv;
	g_source_destroy(self->source);
	g_source_unref(self->source);
	return 0;
}

GArray * alsa_mixer_mixer_get_elements(AlsaMixerMixer * self) {

	GArray * elements = g_array_new(FALSE, FALSE, sizeof(AlsaMixerElement *));
	for (snd_mixer_elem_t * elem = snd_mixer_first_elem(self->mixer); elem != NULL; elem = snd_mixer_elem_next(elem)) {
		AlsaMixerElement * element = alsa_mixer_element_new(elem);
		g_array_append_val(elements, element);
	}

	return elements;
}

AlsaMixerElement * alsa_mixer_mixer_get_element(AlsaMixerMixer * self, const char * name, unsigned int index) {

	snd_mixer_selem_id_t * id;
	snd_mixer_selem_id_alloca(&id);
	snd_mixer_selem_id_set_name(id, name);
	snd_mixer_selem_id_set_index(id, index);

	snd_mixer_elem_t * elem;
	if ((elem = snd_mixer_find_selem(self->mixer, id)) == NULL)
		return NULL;

	AlsaMixerElement * element = alsa_mixer_element_new(elem);
	return element;
}
