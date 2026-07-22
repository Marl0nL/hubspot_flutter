package io.github.marl0nl.hubspot_flutter_chat

import android.app.Activity
import android.content.Context
import android.content.Intent
import com.hubspot.mobilesdk.HubspotManager
import com.hubspot.mobilesdk.HubspotWebActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

/**
 * Android implementation of the hubspot_flutter chat bridge.
 *
 * It implements the Pigeon-generated [HubspotChatHostApi] and forwards each
 * call to HubSpot's official mobile chat SDK (`com.hubspot.mobilesdk`,
 * artifact `com.hubspot.mobilechatsdk:mobile-chat-sdk-android`). The SDK reads
 * its configuration from `assets/hubspot-info.json`; see the package README.
 *
 * Native → Dart chat events are delivered through [HubspotChatFlutterApi],
 * exposed to Dart as broadcast streams.
 */
class HubspotChatPlugin :
    FlutterPlugin,
    ActivityAware,
    HubspotChatHostApi {

    private lateinit var context: Context
    private var activity: Activity? = null
    private var defaultChatFlow: String? = null
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

    companion object {
        private const val CONFIG_ERROR = "hubspot_configuration_error"
        private const val NO_ACTIVITY = "no_activity"

        /** Set while an engine is attached so events can be sent to Dart. */
        @Volatile
        var flutterApi: HubspotChatFlutterApi? = null
            private set
    }

    // --- FlutterPlugin ---

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        HubspotChatHostApi.setUp(binding.binaryMessenger, this)
        flutterApi = HubspotChatFlutterApi(binding.binaryMessenger)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        HubspotChatHostApi.setUp(binding.binaryMessenger, null)
        flutterApi = null
        scope.cancel()
    }

    // --- ActivityAware (openChat needs a foreground Activity) ---

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    private fun manager(): HubspotManager = HubspotManager.getInstance(context)

    // --- HubspotChatHostApi ---

    override fun configure(setup: ChatSetupData, callback: (Result<Unit>) -> Unit) {
        defaultChatFlow = setup.defaultChatFlow
        try {
            // Loads assets/hubspot-info.json (portalId, hublet, environment...).
            manager().configure()
            callback(Result.success(Unit))
        } catch (e: Throwable) {
            callback(Result.failure(flutterError(CONFIG_ERROR, e.message)))
        }
    }

    override fun openChat(chatFlow: String?, callback: (Result<Unit>) -> Unit) {
        val host = activity
        if (host == null) {
            callback(
                Result.failure(
                    flutterError(NO_ACTIVITY, "No foreground Activity to present chat"),
                ),
            )
            return
        }
        // Pigeon's generated handler does not catch synchronous throws, so any
        // SDK/framework exception must be funnelled into the callback here (an
        // escaped exception would crash the app and hang the Dart future).
        try {
            val intent = Intent(host, HubspotWebActivity::class.java)
            (chatFlow ?: defaultChatFlow)?.let { intent.putExtra("chatflow", it) }
            host.startActivity(intent)
            flutterApi?.onChatOpened {}
            callback(Result.success(Unit))
        } catch (e: Throwable) {
            callback(Result.failure(flutterError(CONFIG_ERROR, e.message)))
        }
    }

    override fun closeChat(callback: (Result<Unit>) -> Unit) {
        // HubspotWebActivity is a full-screen Activity the user dismisses; the
        // SDK exposes no programmatic close, so this is a no-op success.
        callback(Result.success(Unit))
    }

    override fun setUserIdentity(
        identity: VisitorIdentity,
        callback: (Result<Unit>) -> Unit,
    ) {
        try {
            manager().setUserIdentity(identity.email, identity.identityToken)
            callback(Result.success(Unit))
        } catch (e: Throwable) {
            callback(Result.failure(flutterError(CONFIG_ERROR, e.message)))
        }
    }

    override fun setChatProperties(
        properties: Map<String, String>,
        callback: (Result<Unit>) -> Unit,
    ) {
        try {
            manager().setChatProperties(properties)
            callback(Result.success(Unit))
        } catch (e: Throwable) {
            callback(Result.failure(flutterError(CONFIG_ERROR, e.message)))
        }
    }

    override fun setPushToken(token: String, callback: (Result<Unit>) -> Unit) {
        scope.launch {
            try {
                manager().setPushToken(token)
                callback(Result.success(Unit))
            } catch (e: Exception) {
                callback(Result.failure(flutterError(CONFIG_ERROR, e.message)))
            }
        }
    }

    override fun handlePushNotification(
        data: Map<String, String>,
        callback: (Result<Boolean>) -> Unit,
    ) {
        try {
            val isHubspot = HubspotManager.isHubspotNotification(data)
            if (isHubspot) flutterApi?.onNewMessage {}
            callback(Result.success(isHubspot))
        } catch (e: Throwable) {
            callback(Result.failure(flutterError(CONFIG_ERROR, e.message)))
        }
    }

    override fun logout(callback: (Result<Unit>) -> Unit) {
        scope.launch {
            try {
                manager().logout()
                callback(Result.success(Unit))
            } catch (e: Exception) {
                callback(Result.failure(flutterError(CONFIG_ERROR, e.message)))
            }
        }
    }

    private fun flutterError(code: String, message: String?): FlutterError =
        FlutterError(code, message, null)
}
