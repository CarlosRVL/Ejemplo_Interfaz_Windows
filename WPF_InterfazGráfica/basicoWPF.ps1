###############################################################
# Ejemplo de interfaz windows usando WPF
###############################################################

# -----
# $PSScriptRoot: Es una variable automática de PowerShell que apunta al directorio
# donde se encuentra el script .ps1. Esto garantiza que siempre encontrará el archivo
# .xaml si están en el mismo directorio.
# Get-Content: Lee el texto del archivo .xaml y lo almacena en la variable $xaml.
# -----

# ----------------------------------------------------------------------
# 1. SETUP: Carga de librerías y definición de la ruta del XAML
# ----------------------------------------------------------------------

# Cargar las librerías necesarias para WPF
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

# Ruta del archivo XAML (asume que está en el mismo directorio que este .ps1)
$XamlPath = (Join-Path $PSScriptRoot "VentanaPrincipal.xaml")

# Comprobar si el archivo XAML existe antes de continuar
if (-not (Test-Path $XamlPath)) {
    Write-Error "El archivo XAML no se encuentra en la ruta: $XamlPath"
    Write-Error "Asegúrese de haber guardado el diseño en 'VentanaPrincipal.xaml'."
    exit 1
}

# 2. CARGA DEL XAML: Leer y convertir el diseño de la interfaz
# ----------------------------------------------------------------------
try {
    # Leer el contenido del archivo XAML y cargarlo como objeto XML
    [xml]$xaml = Get-Content -Path $XamlPath -Encoding UTF8 
    
    # Crear el lector XAML
    $reader = [System.Xml.XmlNodeReader]::new($xaml)

    # Convertir el XAML en la interfaz de WPF (el objeto de la ventana)
    $Form = [Windows.Markup.XamlReader]::Load($reader)
}
catch {
    Write-Error "Error al cargar o parsear el archivo XAML. Verifique su sintaxis."
    Write-Error $_.Exception.Message
    exit 1
}

# 3. OBTENER REFERENCIAS: Enlazar las variables de PowerShell con los controles de la GUI
# ----------------------------------------------------------------------
# NOTA: Los nombres ('RunButton', 'OutputTextBox') deben coincidir con los atributos Name="" del XAML
$RunButton = $Form.FindName('RunButton')
$OutputTextBox = $Form.FindName('OutputTextBox')


# 4. FUNCIONES: Lógica para actualizar la interfaz
# ----------------------------------------------------------------------

# Función para escribir la salida en el cuadro de texto de forma segura (Dispatcher)
Function Write-GuiOutput {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    # Usa el Dispatcher para actualizar la GUI desde cualquier hilo de forma segura
    $OutputTextBox.Dispatcher.Invoke([Action[string]] {
        $OutputTextBox.AppendText("$Message`r`n")
        # Asegura que el scroll se mantenga abajo
        $OutputTextBox.ScrollToEnd()
    }, $Message)
}

# 5. ACCIÓN PRINCIPAL: La lógica de tu script (se ejecuta en un hilo separado)
# ----------------------------------------------------------------------
$ScriptLogic = {
    # Referenciar las variables del ámbito principal del script
    param($RunButton, $OutputTextBox, [scriptblock]$WriteGuiOutput)

    # Deshabilitar el botón mientras se ejecuta (llamada segura al Dispatcher)
    $RunButton.Dispatcher.Invoke([Action]{ $RunButton.IsEnabled = $false })

    . $WriteGuiOutput "--- Iniciando la ejecución del script (WPF) ---"

    # --- INICIO DE TU LÓGICA DE COMANDOS REALES ---
    
    . $WriteGuiOutput "Paso 1: Obteniendo información de la hora actual..."
    Start-Sleep -Seconds 1
    
    # Comando de ejemplo real
    $time = Get-Date -Format "HH:mm:ss"
    . $WriteGuiOutput "Hora actual del sistema: $time"
    
    Start-Sleep -Seconds 2

    . $WriteGuiOutput "Paso 2: Buscando procesos..."
    $processCount = (Get-Process).Count
    . $WriteGuiOutput "Número total de procesos en ejecución: $processCount"

    # --- RESUMEN FINAL ---
    . $WriteGuiOutput ""
    . $WriteGuiOutput "========================================"
    . $WriteGuiOutput "RESUMEN FINAL: Ejecución completada."
    . $WriteGuiOutput "========================================"

    # Volver a habilitar el botón
    $RunButton.Dispatcher.Invoke([Action]{ $RunButton.IsEnabled = $true })
}


# 6. MANEJO DE EVENTOS: Asignar la acción al botón
# ----------------------------------------------------------------------

$RunButton.Add_Click({ 
    # Ejecuta la lógica del script en un nuevo 'Job' para evitar que la GUI se congele
    # Pasamos las referencias de las variables y la función Write-GuiOutput al nuevo hilo
    Start-Job -ScriptBlock $ScriptLogic -Name 'WPFJob' `
              -ArgumentList $RunButton, $OutputTextBox, (Get-Command Write-GuiOutput).ScriptBlock | Out-Null
})


# 7. EJECUCIÓN: Mostrar la ventana
# ----------------------------------------------------------------------

# Muestra el formulario y bloquea el script hasta que se cierra la ventana
[void]$Form.ShowDialog()
