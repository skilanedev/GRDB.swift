#include "sqlite3.h"

int disable_sqlite_memstatus() {
    return sqlite3_config(SQLITE_CONFIG_MEMSTATUS, 0);
}