package com.wsg.vcamsimplifier.data.repository

import com.topjohnwu.superuser.Shell
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

import java.util.concurrent.TimeUnit

/**
 * Privileged Repository - All root operations go through here.
 * Uses libsu exclusively.
 */
object RootRepository {

    init {
        Shell.enableVerboseLogging = true
        Shell.setDefaultBuilder(
            Shell.Builder.create()
                .setFlags(Shell.FLAG_REDIRECT_STDERR)
                .setTimeout(30, TimeUnit.SECONDS)
        )
    }

    suspend fun isRootAvailable(): Boolean = withContext(Dispatchers.IO) {
        runCatching {
            val result = Shell.cmd("id").exec()
            result.isSuccess && result.out.any { it.contains("uid=0") }
        }.getOrDefault(false)
    }

    suspend fun executeCommand(cmd: String): Shell.Result = withContext(Dispatchers.IO) {
        Shell.cmd(cmd).exec()
    }

    // Future methods for media placement, flag files, FFmpeg, etc.
    suspend fun createFlagFile(path: String, name: String): Boolean {
        val result = executeCommand("mkdir -p $path && touch $path/$name")
        return result.isSuccess
    }

    suspend fun deleteFlagFile(path: String, name: String): Boolean {
        val result = executeCommand("rm -f $path/$name")
        return result.isSuccess
    }
}