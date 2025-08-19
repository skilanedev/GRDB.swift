#include "shim.h"
#include <stddef.h>  // For NULL definition

void _registerErrorLogCallback(_errorLogCallback callback) {
    sqlite3_config(SQLITE_CONFIG_LOG, callback, 0);
}

#if SQLITE_VERSION_NUMBER >= 3029000
void _disableDoubleQuotedStringLiterals(sqlite3 *db) {
    sqlite3_db_config(db, SQLITE_DBCONFIG_DQS_DDL, 0, (void *)0);
    sqlite3_db_config(db, SQLITE_DBCONFIG_DQS_DML, 0, (void *)0);
}

void _enableDoubleQuotedStringLiterals(sqlite3 *db) {
    sqlite3_db_config(db, SQLITE_DBCONFIG_DQS_DDL, 1, (void *)0);
    sqlite3_db_config(db, SQLITE_DBCONFIG_DQS_DML, 1, (void *)0);
}
#else
void _disableDoubleQuotedStringLiterals(sqlite3 *db) { }
void _enableDoubleQuotedStringLiterals(sqlite3 *db) { }
#endif

void sqlite3_vec_auto_init(void) {
    char *pzErrMsg = NULL;
    int rc = sqlite3_vec_init(NULL, &pzErrMsg, NULL);
    if (rc != SQLITE_OK && pzErrMsg) {
        (sqlite3_free)(pzErrMsg);
    }
}