# 1. Cargar las librerías necesarias
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Variables y Componentes de la GUI ---

# 2. Crear el Formulario (Ventana Principal)
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Ejecutor de Comandos Sencillo"
$Form.Size = New-Object System.Drawing.Size(550, 450)
$Form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

# 3. Crear el Cuadro de Texto de Salida (donde se verá el resultado)
$TextBoxOutput = New-Object System.Windows.Forms.TextBox
$TextBoxOutput.Location = New-Object System.Drawing.Point(10, 50)
$TextBoxOutput.Size = New-Object System.Drawing.Size(510, 320)
$TextBoxOutput.Multiline = $true # Crucial para ver varias líneas
$TextBoxOutput.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical # Barras de desplazamiento
$TextBoxOutput.ReadOnly = $true # El usuario no debe editar la salida
$Form.Controls.Add($TextBoxOutput)

# 4. Crear el Botón para Ejecutar
$ButtonRun = New-Object System.Windows.Forms.Button
$ButtonRun.Text = "Ejecutar Script"
$ButtonRun.Location = New-Object System.Drawing.Point(10, 10)
$ButtonRun.Size = New-Object System.Drawing.Size(120, 30)
$Form.Controls.Add($ButtonRun)

# --- Lógica del Script ---

# 5. Función para escribir la salida en el cuadro de texto
Function Write-GuiOutput {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    # Añade el mensaje al final del cuadro de texto y fuerza el scroll
    $TextBoxOutput.AppendText("$Message`r`n")
    # Fuerza el refresco de la GUI para actualizar la pantalla inmediatamente
    [System.Windows.Forms.Application]::DoEvents()
}

# 6. Definir la Acción del Botón
$Action = {
    # Deshabilita el botón mientras se ejecuta para evitar clics múltiples
    $ButtonRun.Enabled = $false
    Write-GuiOutput "--- Iniciando la ejecución del script ---"

    # --- INICIO DE TU LÓGICA DE COMANDOS ---
    
    # Simulación de comandos con retardo para ver la actualización en tiempo real
    Write-GuiOutput "Paso 1: Obteniendo información del sistema..."
    Start-Sleep -Seconds 1
    
    # Aquí puedes reemplazar con comandos reales, por ejemplo:
    # $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
    # Write-GuiOutput "Sistema Operativo: $($osInfo.Caption)"
    Write-GuiOutput "Ejecutando ipconfig /all..."
    $ipconfigOutput = (ipconfig /all | Select-Object -First 5) -join "`n"
    Write-GuiOutput $ipconfigOutput
    
    Start-Sleep -Seconds 2

    Write-GuiOutput "Paso 2: Buscando el proceso 'explorer'..."
    $explorerCount = (Get-Process -Name explorer).Count
    Write-GuiOutput "Se encontraron $($explorerCount) instancias de explorer.exe."

    # --- RESUMEN FINAL ---
    Write-GuiOutput ""
    Write-GuiOutput "========================================"
    Write-GuiOutput "RESUMEN FINAL: Ejecución completada."
    Write-GuiOutput "========================================"

    # Vuelve a habilitar el botón
    $ButtonRun.Enabled = $true
}

# 7. Asignar la acción al evento Click del botón
$ButtonRun.Add_Click($Action)

# 8. Mostrar el Formulario (esto bloquea el script hasta que se cierra la ventana)
[void]$Form.ShowDialog()
