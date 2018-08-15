Add-Type -TypeDefinition @"
namespace AnyBox {
	public enum InputType {
		None, Text, FileOpen, FileSave, FolderOpen, Checkbox, Password, Date, Link
	};
	
	public enum MessagePosition { Top, Left };
	public enum SetPresentation { ComboBox, Radio, Radio_Wide };

	public class Prompt
	{
		public string Name;
		public string Tab;
		public string Group;
		public InputType InputType = InputType.Text;
		public string Message;
		public MessagePosition MessagePosition = MessagePosition.Top;
		public string Alignment;
		public System.UInt16 FontSize;
		public string FontFamily;
		public string FontColor;
		public string DefaultValue;
		public System.UInt16 LineHeight = 1;
		public bool ReadOnly = false;
		public string[] ValidateSet;
		public SetPresentation ShowSetAs = SetPresentation.ComboBox;
		public string RadioGroup;
		public bool ValidateNotEmpty = false;
		public System.Management.Automation.ScriptBlock ValidateScript;
		public bool ShowSeparator = false;
		public bool Collapsible = false;
	}

	public class Button
	{
		public string Name;
		public string Text;
		public bool IsCancel = false;
		public bool IsDefault = false;
		public System.Management.Automation.ScriptBlock OnClick;
	}
}
"@

function New-AnyBoxPrompt
{
	[cmdletbinding()]
	param(
		[string]$Message,
		[string]$Name,
		[string]$Tab,
		[string]$Group,
		[ValidateNotNullOrEmpty()]
		[AnyBox.InputType]$InputType = [AnyBox.InputType]::Text,
		[ValidateNotNullOrEmpty()]
		[AnyBox.MessagePosition]$MessagePosition = [AnyBox.MessagePosition]::Top,
		[System.Windows.HorizontalAlignment]$Alignment,
		[UInt16]$FontSize,
		[string]$FontFamily,
		[string]$FontColor,
		[string]$DefaultValue,
		[ValidateScript({$_ -gt 0})]
		[UInt16]$LineHeight = 1,
		[switch]$ReadOnly,
		[switch]$ValidateNotEmpty,
		[string[]]$ValidateSet,
		[AnyBox.SetPresentation]$ShowSetAs = [AnyBox.SetPresentation]::ComboBox,
		[string]$RadioGroup,
		[System.Management.Automation.ScriptBlock]$ValidateScript,
		[switch]$ShowSeparator,
		[switch]$Collapsible
	)

	if ($Name -and $Name -notmatch '^[A-Za-z_]+[A-Za-z0-9_]*$') {
		Write-Warning "Name must start with a letter or the underscore character (_), and must contain only letters, digits, or underscores."
		$Name = $null
	}

	if ($InputType -ne [AnyBox.InputType]::Text)
	{
		if ($InputType -eq [AnyBox.InputType]::None) {
			return($null)
		}

		if ($LineHeight -gt 1) {
			Write-Warning "'-LineHeight' parameter is only valid with text input."
		}

		if ($InputType -eq [AnyBox.InputType]::Checkbox) {
			if (-not $Message) {
				Write-Error "Checkbox input requires a message."
				break
			}
		}
		elseif ($InputType -eq [AnyBox.InputType]::Link) {
			if (-not $Message) {
				Write-Error "Checkbox input requires a message."
				break
			}
			if (-not $FontColor) {
				$FontColor = 'Blue'
			}
		}
		elseif ($InputType -eq [AnyBox.InputType]::Password) {
			if ($DefaultValue) {
				Write-Warning 'Password input does not accept a default value.'
				$DefaultValue = $null
			}
		}
	}
	
	$p = New-Object AnyBox.Prompt

	$p.Name = $Name
	$p.Tab = $Tab
	$p.Group = $Group
	$p.InputType = $InputType
	$p.ReadOnly = $ReadOnly -as [bool]
	$p.Message = $Message
	$p.Alignment = $Alignment
	$p.FontColor = $FontColor
	$p.FontFamily = $FontFamily
	$p.FontSize = $FontSize
	$p.MessagePosition = $MessagePosition
	$p.DefaultValue = $DefaultValue
	$p.LineHeight = $LineHeight
	$p.ValidateNotEmpty = $ValidateNotEmpty -as [bool]
	$p.ValidateSet = $ValidateSet
	$p.ShowSetAs = $ShowSetAs
	$p.RadioGroup = $RadioGroup
	$p.ValidateScript = $ValidateScript
	$p.ShowSeparator = $ShowSeparator -as [bool]
	$p.Collapsible = $Collapsible -as [bool]

	return($p)
}

function New-AnyBoxButton
{
	[cmdletbinding()]
	param(
		[ValidateNotNull()]
		[string]$Text,
		[string]$Name,
		[switch]$IsCancel,
		[switch]$IsDefault,
		[System.Management.Automation.ScriptBlock]$OnClick
	)

	if ($Name -and $Name -notmatch '^[A-Za-z_]+[A-Za-z0-9_]*$') {
		Write-Warning "Name must start with a letter or the underscore character (_), and must contain only letters, digits, or underscores."
		$Name = $null
	}

	$b = New-Object AnyBox.Button

	$b.Name = $Name
	$b.Text = $Text
	$b.IsCancel = $IsCancel -as [bool]
	$b.IsDefault = $IsDefault -as [bool]
	$b.OnClick = $OnClick

	return($b)
}

Set-Alias -Name 'New-Prompt' -Value 'New-AnyBoxPrompt' -Description 'New-AnyBoxPrompt'
Set-Alias -Name 'New-Button' -Value 'New-AnyBoxButton' -Description 'New-AnyBoxButton'