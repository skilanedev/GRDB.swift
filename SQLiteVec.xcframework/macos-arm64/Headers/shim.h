#include <sqlite3.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef void(*_errorLogCallback)(void *pArg, int iErrCode, const char *zMsg);

extern void _registerErrorLogCallback(_errorLogCallback callback);

#if SQLITE_VERSION_NUMBER >= 3029000
extern void _disableDoubleQuotedStringLiterals(sqlite3 *db);

extern void _enableDoubleQuotedStringLiterals(sqlite3 *db);
#else
extern void _disableDoubleQuotedStringLiterals(sqlite3 *db);

extern void _enableDoubleQuotedStringLiterals(sqlite3 *db);

extern int sqlite3_vec_init(sqlite3 *db, char **pzErrMsg, const sqlite3_api_routines *pApi);

extern int sqlite3_vec_init(sqlite3 *db, char **pzErrMsg, const sqlite3_api_routines *pApi);

extern int sqlite3_vec_init(sqlite3 *db, char **pzErrMsg, const void *pApi);

extern void sqlite3_free(void *p);
#endif

// Expose APIs that are missing from system <sqlite3.h>
#ifdef GRDB_SQLITE_ENABLE_PREUPDATE_HOOK
SQLITE_API void *sqlite3_preupdate_hook(
  sqlite3 *db,
  void(*xPreUpdate)(
    void *pCtx,                   /* Copy of third arg to preupdate_hook() */
    sqlite3 *db,                  /* Database handle */
    int op,                       /* SQLITE_UPDATE, DELETE or INSERT */
    char const *zDb,              /* Database name */
    char const *zName,            /* Table name */
    sqlite3_int64 iKey1,          /* Rowid of row about to be deleted/updated */
    sqlite3_int64 iKey2           /* New rowid value (for a rowid UPDATE) */
  ),
  void*
);
SQLITE_API int sqlite3_preupdate_old(sqlite3 *, int, sqlite3_value **);
SQLITE_API int sqlite3_preupdate_count(sqlite3 *);
SQLITE_API int sqlite3_preupdate_depth(sqlite3 *);
SQLITE_API int sqlite3_preupdate_new(sqlite3 *, int, sqlite3_value **);
#endif /* GRDB_SQLITE_ENABLE_PREUPDATE_HOOK */

#ifdef __cplusplus
}
#endif