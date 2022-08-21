/*
 * Erlang NIF bindings for libmagic
 */

#include "erl_nif.h"

#include <stdio.h>
#include <string.h>
#include <magic.h>

ErlNifResourceType *MAGIC_RES_TYPE;

void magic_res_destructor(ErlNifEnv *env, void *res) {
  magic_t *m = (magic_t *)res;
  magic_close(*m);
}

int load(ErlNifEnv *env, void **priv_data, ERL_NIF_TERM load_info) {
  int flags = ERL_NIF_RT_CREATE | ERL_NIF_RT_TAKEOVER;
  MAGIC_RES_TYPE = enif_open_resource_type(env, "nif", "Magic", magic_res_destructor, flags, NULL);
  return 0;
}

static ERL_NIF_TERM magic_init_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  magic_t *m = enif_alloc_resource(MAGIC_RES_TYPE, sizeof(magic_t));
  *m = magic_open(MAGIC_MIME_TYPE);
  magic_load(*m, NULL);

  ERL_NIF_TERM term = enif_make_resource(env, m);
  enif_release_resource(m);

  return term;
}

static ERL_NIF_TERM magic_buffer_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  magic_t *m;
  ErlNifBinary bin;

  if (!enif_get_resource(env, argv[0], MAGIC_RES_TYPE, (void*) &m)) {
    return enif_make_badarg(env);
  }

  if (enif_inspect_binary(env, argv[1], &bin)) {
    const char* str = magic_buffer(*m, bin.data, bin.size);

    if (str != NULL) {
      ERL_NIF_TERM ret_term;
      size_t len = strlen(str);
      unsigned char *ret = enif_make_new_binary(env, len, &ret_term);
      memcpy(ret, str, len);

      return enif_make_tuple2(env, enif_make_atom(env, "ok"), ret_term);
    } else {
      return enif_make_atom(env, "error");
    }
  }

  return enif_make_badarg(env);
}

static ErlNifFunc nif_funcs[] = {
  {"create", 0, magic_init_nif},
  {"buffer", 2, magic_buffer_nif},
};

ERL_NIF_INIT(Elixir.Magic, nif_funcs, &load, NULL, NULL, NULL);
