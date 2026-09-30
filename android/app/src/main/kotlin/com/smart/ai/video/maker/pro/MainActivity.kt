package com.smart.ai.video.maker.pro

import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.os.RemoteException
import android.util.Log
import com.android.installreferrer.api.InstallReferrerClient
import com.android.installreferrer.api.InstallReferrerStateListener
import com.android.installreferrer.api.ReferrerDetails
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.smart.ai.video.maker.pro/app_launcher"
    private val REFERRER_CHANNEL = "com.smart.ai.video.maker.pro/install_referrer"
    private val TARGET_PACKAGE = "com.free.video.view"
    private val TAG = "MainActivityLauncher"

    private val packageReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val pkg = intent?.data?.schemeSpecificPart
            Log.d(TAG, "Package added broadcast received: $pkg")
            if (pkg == TARGET_PACKAGE || isPackageInstalled(TARGET_PACKAGE)) {
                checkAndOpenTarget("BroadcastReceiver")
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        try {
            val filter = IntentFilter(Intent.ACTION_PACKAGE_ADDED).apply {
                addDataScheme("package")
            }
            registerReceiver(packageReceiver, filter)
        } catch (e: Exception) {
            Log.e(TAG, "Error registering packageReceiver: ${e.message}")
        }
        checkAndOpenTarget("onCreate")
    }

    override fun onResume() {
        super.onResume()
        checkAndOpenTarget("onResume")
    }

    override fun onDestroy() {
        super.onDestroy()
        try {
            unregisterReceiver(packageReceiver)
        } catch (_: Exception) {}
    }

    private var isLaunchingTarget = false

    private fun checkAndOpenTarget(source: String) {
        if (isLaunchingTarget) return
        if (isPackageInstalled(TARGET_PACKAGE)) {
            isLaunchingTarget = true
            Log.d(TAG, "Target app $TARGET_PACKAGE is installed! Opening immediately from native $source...")
            if (openPackage(TARGET_PACKAGE)) {
                Log.d(TAG, "Successfully launched $TARGET_PACKAGE. Closing wrapper.")
                finish()
            } else {
                isLaunchingTarget = false
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ---- App Launcher Channel ----
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAppInstalled" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) result.success(isPackageInstalled(packageName))
                    else result.error("INVALID_ARGUMENT", "Package name cannot be null", null)
                }
                "openApp" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        val opened = openPackage(packageName)
                        if (opened) {
                            Log.d(TAG, "Successfully launched $packageName from openApp. Closing wrapper.")
                            finish()
                        }
                        result.success(opened)
                    } else result.error("INVALID_ARGUMENT", "Package name cannot be null", null)
                }
                "openBrowser" -> {
                    val url = call.argument<String>("url")
                    if (url != null) result.success(openInBrowser(url))
                    else result.error("INVALID_ARGUMENT", "URL cannot be null", null)
                }
                else -> result.notImplemented()
            }
        }

        // ---- Install Referrer Channel ----
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, REFERRER_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstallReferrer" -> readInstallReferrer(result)
                else -> result.notImplemented()
            }
        }
    }

    /**
     * Reads the Google Play Install Referrer string.
     * CPI Google Ads campaigns produce referrers like:
     *   utm_source=google&utm_medium=cpi&gclid=CjwKCAjw...
     * Returns empty string on error/unavailable (treated as non-Google).
     */
    private fun readInstallReferrer(result: MethodChannel.Result) {
        val referrerClient = InstallReferrerClient.newBuilder(this).build()
        var resultSent = false

        referrerClient.startConnection(object : InstallReferrerStateListener {
            override fun onInstallReferrerSetupFinished(responseCode: Int) {
                if (resultSent) return
                resultSent = true
                when (responseCode) {
                    InstallReferrerClient.InstallReferrerResponse.OK -> {
                        try {
                            val referrerDetails: ReferrerDetails = referrerClient.installReferrer
                            val referrerUrl = referrerDetails.installReferrer ?: ""
                            Log.d(TAG, "[Referrer] Raw: $referrerUrl")
                            try { referrerClient.endConnection() } catch (_: Exception) {}
                            result.success(referrerUrl)
                        } catch (e: RemoteException) {
                            Log.e(TAG, "[Referrer] RemoteException: ${e.message}")
                            try { referrerClient.endConnection() } catch (_: Exception) {}
                            result.success("")
                        } catch (e: Exception) {
                            Log.e(TAG, "[Referrer] Error: ${e.message}")
                            try { referrerClient.endConnection() } catch (_: Exception) {}
                            result.success("")
                        }
                    }
                    else -> {
                        Log.w(TAG, "[Referrer] Response code: $responseCode")
                        try { referrerClient.endConnection() } catch (_: Exception) {}
                        result.success("")
                    }
                }
            }

            override fun onInstallReferrerServiceDisconnected() {
                Log.w(TAG, "[Referrer] Service disconnected")
                if (!resultSent) {
                    resultSent = true
                    result.success("")
                }
            }
        })
    }

    private fun isPackageInstalled(packageName: String): Boolean {
        return try {
            packageManager.getPackageInfo(packageName, 0)
            true
        } catch (e: PackageManager.NameNotFoundException) { false
        } catch (e: Exception) { false }
    }

    private fun openPackage(packageName: String): Boolean {
        return try {
            Log.d(TAG, "Attempting to open package: $packageName")
            var launchIntent = packageManager.getLaunchIntentForPackage(packageName)
            if (launchIntent == null) {
                try {
                    val packageInfo = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
                        packageManager.getPackageInfo(packageName, PackageManager.PackageInfoFlags.of(PackageManager.GET_ACTIVITIES.toLong()))
                    } else {
                        @Suppress("DEPRECATION")
                        packageManager.getPackageInfo(packageName, PackageManager.GET_ACTIVITIES)
                    }
                    val activities = packageInfo.activities
                    if (activities != null) {
                        for (activity in activities) {
                            if (activity.exported) {
                                launchIntent = Intent().apply {
                                    component = ComponentName(packageName, activity.name)
                                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                }
                                break
                            }
                        }
                    }
                } catch (e: Exception) { Log.e(TAG, "Error getting activities: ${e.message}") }
            }
            if (launchIntent == null && packageName == "com.free.video.view") {
                launchIntent = Intent().apply {
                    component = ComponentName("com.free.video.view", "app.lawnchair.LawnchairLauncher")
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
            }
            if (launchIntent != null) {
                launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(launchIntent)
                true
            } else { false }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to open package $packageName: ${e.message}")
            false
        }
    }

    private var lastBrowserOpenTime = 0L

    private fun openInBrowser(url: String): Boolean {
        val now = System.currentTimeMillis()
        if (now - lastBrowserOpenTime < 2500L) {
            Log.d(TAG, "openInBrowser called too rapidly — ignoring duplicate invocation")
            return true
        }
        lastBrowserOpenTime = now

        val uri = Uri.parse(url)
        return try {
            // Priority 1: Always try Google Chrome directly
            val chromeIntent = Intent(Intent.ACTION_VIEW, uri).apply {
                setPackage("com.android.chrome")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(chromeIntent)
            Log.d(TAG, "Successfully opened in Google Chrome: $url")
            true
        } catch (e: Exception) {
            Log.w(TAG, "Chrome not found or failed, falling back to default browser: ${e.message}")
            try {
                // Priority 2: Fallback to system default external browser
                val fallbackIntent = Intent(Intent.ACTION_VIEW, uri).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(fallbackIntent)
                Log.d(TAG, "Successfully opened in fallback browser: $url")
                true
            } catch (e2: Exception) {
                Log.e(TAG, "Failed to open any browser: ${e2.message}")
                false
            }
        }
    }
}
