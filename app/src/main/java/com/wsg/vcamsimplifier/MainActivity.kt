package com.wsg.vcamsimplifier

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.wsg.vcamsimplifier.data.repository.RootRepository
import com.wsg.vcamsimplifier.ui.theme.VCamSimplifierTheme
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            VCamSimplifierTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    VCamApp()
                }
            }
        }
    }
}

@Composable
fun VCamApp() {
    val scope = rememberCoroutineScope()
    var rootStatus by remember { mutableStateOf("Checking...") }
    var isRooted by remember { mutableStateOf(false) }

    LaunchedEffect(Unit) {
        scope.launch {
            isRooted = RootRepository.isRootAvailable()
            rootStatus = if (isRooted) {
                "Root access granted ✓"
            } else {
                "No root access. Please grant root permission."
            }
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            text = "VCam Simplifier",
            style = MaterialTheme.typography.headlineLarge
        )
        Spacer(modifier = Modifier.height(32.dp))

        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(
                containerColor = if (isRooted) 
                    MaterialTheme.colorScheme.primaryContainer 
                else 
                    MaterialTheme.colorScheme.errorContainer
            )
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Text(
                    text = "System Status",
                    style = MaterialTheme.typography.titleMedium
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(rootStatus)
            }
        }

        Spacer(modifier = Modifier.height(24.dp))

        Button(
            onClick = {
                scope.launch {
                    // Placeholder for future actions
                    // Will add media hub, enable toggle, etc.
                }
            },
            enabled = isRooted
        ) {
            Text("Enable Virtual Camera (Coming Soon)")
        }

        Spacer(modifier = Modifier.height(16.dp))

        Text(
            text = "Rooted device detected. Magisk module + this app will provide virtual camera spoofing.",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}