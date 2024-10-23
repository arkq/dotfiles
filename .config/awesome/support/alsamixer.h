/*
 * ALSA Mixer Library for LGI
 *
 * Copyright (c) 2024 Arkadiusz Bokowy
 *
 * Licensed under the terms of the MIT license.
 *
 */

#pragma once

#include <glib-object.h>
#include <glib.h>

/* AlsaMixer.Mixer */

#define ALSA_MIXER_TYPE_MIXER alsa_mixer_mixer_get_type()
G_DECLARE_FINAL_TYPE(AlsaMixerMixer, alsa_mixer_mixer, ALSA_MIXER, MIXER, GObject)

/* AlsaMixer.Element */

#define ALSA_MIXER_TYPE_ELEMENT alsa_mixer_element_get_type()
G_DECLARE_FINAL_TYPE(AlsaMixerElement, alsa_mixer_element, ALSA_MIXER, ELEMENT, GObject)

/* Binding API */

AlsaMixerMixer * alsa_mixer_mixer_new(void);

int alsa_mixer_mixer_attach(AlsaMixerMixer * self, const char * name);
int alsa_mixer_mixer_detach(AlsaMixerMixer * self, const char * name);

/**
 * alsa_mixer_mixer_get_elements:
 * @self: a pointer to AlsaMixerMixer
 *
 * Gets the elements in the mixer.
 *
 * Returns: (element-type AlsaMixerElement) (transfer full): a new GArray of AlsaMixerElement
 */
GArray * alsa_mixer_mixer_get_elements(AlsaMixerMixer * self);

/**
 * alsa_mixer_mixer_get_element:
 * @self: a pointer to AlsaMixerMixer
 * @name: the name of the element
 * @index: the index of the element
 *
 * Finds an element in the mixer.
 *
 * Returns: (transfer full): a new AlsaMixerElement
 */
AlsaMixerElement * alsa_mixer_mixer_get_element(AlsaMixerMixer * self, const char * name, unsigned int index);
