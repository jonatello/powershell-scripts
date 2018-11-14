Function Get-QueueID {
    <#
    .SYNOPSIS
    CDYNE SOAP 1.2 request GetQueueIDStatus
    Author: Jon Rodriguez
    .DESCRIPTION
    Pass this function a QueueID and it will run a SOAP 1.2 request against CDYNE to return the status
    .NOTES
    N/A
    .EXAMPLE
    Get-QueueIDStatus -QueueID 123456
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$QueueID
    )

    #Create properly formatted SOAP 1.2 request in XML format using variables
    [xml]$SOAP = "<?xml version=`"1.0`" encoding=`"utf-8`"?>
    <soap12:Envelope xmlns:xsi=`"http://www.w3.org/2001/XMLSchema-instance`" xmlns:xsd=`"http://www.w3.org/2001/XMLSchema`" xmlns:soap12=`"http://www.w3.org/2003/05/soap-envelope`">
    <soap12:Body>
    <GetQueueIDStatus xmlns=`"http://ws.cdyne.com/NotifyWS/`">
    <QueueID>$QueueID</QueueID>
    </GetQueueIDStatus>
    </soap12:Body>
    </soap12:Envelope>"
    $headers = @{"SOAPAction" = "http://ws.cdyne.com/NotifyWS/GetQueueIDStatus"}
    $URI = "http://ws.cdyne.com/NotifyWS/PhoneNotify.asmx"
    $ContentType = 'application/soap+xml'

    #Invoke SOAP 1.2 request and store in variable
    Try {
        $Response = Invoke-WebRequest -UseBasicParsing $URI -Method Post -ContentType $ContentType -Body $SOAP -Headers $headers
    } Catch {
        Write-Error "There was an error when attempting to get the QueueID $QueueID`n`nError Results:`n`n$_"
    }
    
    #Manipulate response to get only the last digit pressed
    Try {
        $DigitsPressed = ($Response -split "DigitsPressed>")[1].Substring(0,$($Response -split "DigitsPressed>")[1].Length-2)
        $DigitsPressed = $DigitsPressed.Substring($DigitsPressed.Length-1,1)
    } Catch {
        $DigitsPressed = $null
    }

    #Output the DigitsPressed
    Write-Output $DigitsPressed
}

Function Notify-PhoneBasic {
    <#
    .SYNOPSIS
    CDYNE SOAP 1.2 request NotifyPhoneBasic
    Author: Jon Rodriguez
    .DESCRIPTION
    Pass this function a phone number and text to say and it will run a SOAP 1.2 request against CDYNE to place a call
    .NOTES
    N/A
    .EXAMPLE
    Notify-PhoneBasic -PhoneNumber 5555555555 -TextToSay "This is an Emergency!"
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$PhoneNumber,
        [Parameter(Mandatory = $true,Position = 1)]
        [string]$TextToSay,
        [Parameter(Mandatory = $true,Position = 2)]
        [string]$LicenseKey
    )

    #Create properly formatted SOAP 1.2 request in XML format using variables
    [xml]$SOAP =  "<?xml version=`"1.0`" encoding=`"utf-8`"?>
    <soap12:Envelope xmlns:xsi=`"http://www.w3.org/2001/XMLSchema-instance`" xmlns:xsd=`"http://www.w3.org/2001/XMLSchema`" xmlns:soap12=`"http://www.w3.org/2003/05/soap-envelope`">
    <soap12:Body>
        <NotifyPhoneBasic xmlns=`"http://ws.cdyne.com/NotifyWS/`">
        <PhoneNumberToDial>$PhoneNumber</PhoneNumberToDial>
        <TextToSay>
            ~\ActOnDigitPress(false)~
            ~\ClearDTMF()~
            ~\AssignDTMF(1|Verified)~
            ~\ActOnDigitPress(true)~
            $TextToSay
            ~\WaitForDTMF(5)~
            ~\Goto(Start)~
            ~\Label(Verified)~
            ~\Label(Amd)~
            $TextToSay
            ~\EndCall()~     
        </TextToSay>
        <CallerID>8282741196</CallerID>
        <CallerIDname>`"Priority`"</CallerIDname>
        <VoiceID>1</VoiceID>
        <LicenseKey>$LicenseKey</LicenseKey>
        </NotifyPhoneBasic>
    </soap12:Body>
    </soap12:Envelope>"
    $headers = @{"SOAPAction" = "http://ws.cdyne.com/NotifyWS/NotifyPhoneBasic"}
    $URI = "http://ws.cdyne.com/NotifyWS/PhoneNotify.asmx"
    $ContentType = 'application/soap+xml'

    #Invoke SOAP 1.2 request and store in variable
    Try {
        $Response = Invoke-WebRequest -UseBasicParsing $URI -Method Post -ContentType $ContentType -Body $SOAP -Headers $headers
    } Catch {
        Write-Warning "There was an error when attempting to place the call to the phone number $PhoneNumber`n`nError Results:`n`n$_"
    }

    #Manipulate response to get only the QueueID
    Try {
        $QueueID = ($Response -split "QueueID>")[1].Substring(0,$($Response -split "QueueID>")[1].Length-2)
    } Catch {
        $QueueID = $null
    }

    #Write the output of the QueueID if it exists, if not write $False
    Write-Output $QueueID       
}
