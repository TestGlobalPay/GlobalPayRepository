//Intialize CTI
sforce.interaction.cti.disableClickToDial();

var paramString = "";
var gCid,gAni,gIvr,gUcid,gAni2;

var popNewLeadCB = function (response) {
    if (response.result) {
	  if (gIvr == '') {
	    alert('The Client called a call-back number. We created a new Lead for your client.');
	  } else {
        alert("We created a new Lead for your client.");
	  }
    } else {
        alert(response.error);    
    }   
}

var createLeadCB = function (response) {
    if (response.result) {
        sforce.interaction.screenPop(response.result,true,popNewLeadCB);
    } else {
        alert(response.error);    
    }   
}

var aniSearchCB = function (response) {
    if (response.result) {
        if (response.result == "{}" && !isNaN(gAni)) {
          if (gAni2 == '') { 
    sforce.interaction.runApex('CreateCaseWS','createLead',paramString,createLeadCB); 
          } else {
     sforce.interaction.searchAndScreenPop(gAni2,'','inbound',ani2SearchCB);
          }
        } else {
          foundLead (response);  
        }
    } else {
        alert(response.error);    
    }
}

var ani2SearchCB = function (response) {
    if (response.result) {
        if (response.result == "{}") {
   sforce.interaction.runApex('CreateCaseWS','createLead',paramString,createLeadCB);
        } else {
          foundLead (response);  
        }
    } else {
        alert(response.error);    
    }
}

var cidSearchCB = function (response) {
    if (response.result) {
        if (response.result == "{}") {
            if (isNaN(gAni)) {
                sforce.interaction.runApex('CreateCaseWS','createLead',paramString,createLeadCB);
            } else {
                sforce.interaction.searchAndScreenPop(gAni,'','inbound',aniSearchCB);
            }
        } else {
	  foundLead (response);
        }
    } else {
        alert(response.error);    
    }
}

function foundLead (response) {

  var objectId = '';
  var jsonObj = JSON.parse(response.result);

  for (var j in jsonObj) {
    if (j.startsWith('500')) {
      objectId = j;
      break;
    }
  }
  
  sforce.interaction.runApex('CreateCaseWS', 'createAudit', paramString + '&objectId=' + objectId, null);
  alert('We found a match for your client.'); 
}

function doPop (cid,ani,ivr,ucid) {
    gCid = cid;
    gAni = ani;
    gIvr = ivr;
    gUcid = ucid;
    gAni2 = '';
//  alert (cid + "-" + ani + "-" + ivr + "-" + ucid);

    paramString = "cid=" + gCid + "&ani=" + gAni + "&ivr=" + gIvr  + "&ucid=" + gUcid;

    if (gAni.length > 10 && !gAni.startsWith("+")) {
      gAni = "+" + gAni;
    }

    if (gAni.startsWith("+")) {
      var number = parsePhoneNumber(gAni);
      gAni2 = number.getNationalNumber();
      gAni = gAni.replace("+", "");
    }

    if (cid != "") {
        sforce.interaction.searchAndScreenPop(cid,'','inbound',cidSearchCB);
    } else if (gAni != "" && !isNaN(gAni)) {
        sforce.interaction.searchAndScreenPop(gAni,'','inbound',aniSearchCB);
    } else {
      sforce.interaction.runApex('CreateCaseWS','createLead',paramString,createLeadCB);  
    }
//  alert("Screenpop!");
}
function popJSON (json) {
/*
    var json = '{"type":"SCREENPOP","data":{"kind":"screenpop#pop","timestamp":"1429047345904","callId":"00011129581429047330","urls":[{"kind":"screenpop#popUrl",';
    json += '"address":"CID=${CID)&ANI=6502848303&IVR=${IVR}&UCID=${UCID}","foreground":true}]}}';
    json = '{"type":"SCREENPOP","data":{"kind":"screenpop#pop","timestamp":"1429047345904","callId":"00011129581429047330","urls":[{"kind":"screenpop#popUrl",';
    json += '"address":"CID=anywhere&ANI=6502848303&IVR=0009856&UCID=${UCID}","foreground":true}]}}';
*/      
    var obj = JSON.parse(json);
    var addr = obj.data.urls[0].address;
    var xx = addr.split("&");
    for (var i=0;i<xx.length;i++) {
        var xx2 = xx[i].split("=");
        if (xx2[1].startsWith("${")) {
            xx2[1] = "";        
        }
        if(xx2[0] == "CID") gCid = xx2[1];
        if(xx2[0] == "ANI") gAni = xx2[1];
        if(xx2[0] == "IVR") gIvr = xx2[1];
        if(xx2[0] == "UCID") gUcid = xx2[1];    
    }
    doPop (gCid,gAni,gIvr,gUcid);
    //alert(obj.data.urls[0].address);
}

window.addEventListener("message", function(event) {
  // We only accept messages from ourselves
  if (event.source != window) {
//  alert('event source is not window');
//    return;
}
  if (event.data.type && (event.data.type == "SCREENPOP")) {
    console.log("Content script received: " + event.data);
    popJSON (JSON.stringify(event.data));
  }
}, false);

  
  function sendPopsAsJson() {
    window.postMessage({type: 'SCREENPOP_CONFIG', sendPopsAsJson: true}, "*");
  }  
  
function addLoadEvent(func) {
  var oldonload = window.onload;
  if (typeof window.onload != 'function') {
    window.onload = func;
  } else {
    window.onload = function() {
      if (oldonload) {
        oldonload();
      }
      func();
    }
  }
}
addLoadEvent(sendPopsAsJson);
   function checkNumFormat(num) {
      var tempNum = num;
      if(num.charAt(0) == '+') {
        num = num.substring(1, num.length);
      }
      num = num.replace(/[+]/g,' ');
      if(tempNum.charAt(0) == '+') {
        num = '+' + num;
      }
      return num;
   }

   function getFirstOccuranceOfHyphenOrSpace(str) {
      var strLen = str.length;
      var pos = -1;
      for(var i=0; i<strLen; i++) {  
          if (str.charAt(i) == "-" || str.charAt(i) == " ") {
             pos = i;
             break;
          } 
        }
      return pos;
    } 

    function phoneCountryCodes(dispCode, isdCode)
    {
        this.dispCode  = dispCode;
        this.isdCode = isdCode;
    }
    
    function getSeparatedCountryCode(phoneNum) {
        //alert('in...');
        var pCodes = new phoneCountryCodes('', '');
        var dispCode = '';
        var ctryCode = '';
        //alert('in2...'+phoneNum.charAt(1));

        if(phoneNum.charAt(1) == '1') { 
           for(var i=5; i>1;i--) {
              if (i==4 || i==3) continue;
              //alert('for...'+i);
              ctryCode = phoneNum.substring(0, i);
              //alert(ctryCode);
              dispCode = getCountryDisplayCode(ctryCode);
              if(dispCode != '')
                      break; 
           }
        }
        if(phoneNum.charAt(1) == '2' || phoneNum.charAt(1) == '3' || phoneNum.charAt(1) == '4' || phoneNum.charAt(1) == '5' 
           || phoneNum.charAt(1) == '6' || phoneNum.charAt(1) == '8' || phoneNum.charAt(1) == '9')  {  
           for(var i=4; i>2;i--) {
              //alert('for...'+i);
              ctryCode = phoneNum.substring(0, i);
              //alert(ctryCode);
              dispCode = getCountryDisplayCode(ctryCode);
              if(dispCode != '')
                      break; 
           }
        }               
        if(phoneNum.charAt(1) == '7')  {  
           for(var i=2; i>1;i--) {
              //alert('for...'+i);
              ctryCode = phoneNum.substring(0, i);
              //alert(ctryCode);
              dispCode = getCountryDisplayCode(ctryCode);
              if(dispCode != '')
                      break; 
           }
        }
        pCodes.dispCode = dispCode;
        pCodes.isdCode = ctryCode;  
           
        return pCodes;
    }

    function getDefualtDialCode(countryCode)
    {
      var dialCode = '';
      switch (countryCode)
      {
        case 'US':
          dialCode = '+1';
          break;
        case 'IN':
          dialCode = '+91';
          break;
        case 'UK':
          dialCode = '+44';
          break;
        case 'BR':
          dialCode = '+55';
          break;
        case 'FR':
          dialCode = '+33';
          break;
        case 'DE':
          dialCode = '+49';
          break;
        case 'JP':
          dialCode = '+81';
          break;
        case 'CS':
          dialCode = '+381';
          break;
        case 'ZA':
          dialCode = '+27';
          break;
        case 'AF':
          dialCode = '+93';
          break;
        case 'AL':
          dialCode = '+355';
          break;
        case 'DZ':
          dialCode = '+213';
          break;
        case 'AS':
          dialCode = '+1684';
          break;
        case 'AD':
          dialCode = '+376';
          break;
        case 'AO':
          dialCode = '+244';
          break;
        case 'AI':
          dialCode = '+1264';
          break;
        case 'AG':
          dialCode = '+1268';
          break;
        case 'AR':
          dialCode = '+54';
          break;
        case 'AM':
          dialCode = '+374';
          break;
        case 'AW':
          dialCode = '+297';
          break;
        case 'AC':
          dialCode = '+247';
          break;
        case 'AU':
          dialCode = '+61';
          break;
        case 'AT':
          dialCode = '+43';
          break;
        case 'AZ':
          dialCode = '+994';
          break;
        case 'BS':
          dialCode = '+1242';
          break;
        case 'BH':
          dialCode = '+973';
          break;
        case 'BD':
          dialCode = '+880';
          break;
        case 'BB':
          dialCode = '+1246';
          break;
        case 'BY':
          dialCode = '+375';
          break;
        case 'BE':
          dialCode = '+32';
          break;
        case 'BZ':
          dialCode = '+501';
          break;
        case 'BJ':
          dialCode = '+229';
          break;
        case 'BM':
          dialCode = '+1441';
          break;
        case 'BT':
          dialCode = '+975';
          break;
        case 'BO':
          dialCode = '+591';
          break;
        case 'BQ':
          dialCode = '+599';
          break;
        case 'BA':
          dialCode = '+387';
          break;
        case 'BW':
          dialCode = '+267';
          break;
        case 'BN':
          dialCode = '+673';
          break;
        case 'BG':
          dialCode = '+359';
          break;
        case 'BF':
          dialCode = '+226';
          break;
        case 'BI':
          dialCode = '+257';
          break;
        case 'KH':
          dialCode = '+855';
          break;
        case 'CM':
          dialCode = '+237';
          break;
        case 'CA':
          dialCode = '+1';
          break;
        case 'CV':
          dialCode = '+238';
          break;
        case 'KY':
          dialCode = '+1345';
          break;
        case 'CF':
          dialCode = '+236';
          break;
        case 'TD':
          dialCode = '+235';
          break;
        case 'CL':
          dialCode = '+56';
          break;
        case 'CN':
          dialCode = '+86';
          break;
        case 'CO':
          dialCode = '+57';
          break;
        case 'KM':
          dialCode = '+269';
          break;
        case 'CG':
          dialCode = '+242';
          break;
        case 'CD':
          dialCode = '+243';
          break;
        case 'CK':
          dialCode = '+682';
          break;
        case 'CR':
          dialCode = '+506';
          break;
        case 'CI':
          dialCode = '+225';
          break;
        case 'HR':
          dialCode = '+385';
          break;
        case 'CU':
          dialCode = '+53';
          break;
        case 'CW':
          dialCode = '+599';
          break;
        case 'CY':
          dialCode = '+357';
          break;
        case 'CZ':
          dialCode = '+420';
          break;
        case 'DK':
          dialCode = '+45';
          break;
        case 'DG':
          dialCode = '+246';
          break;
        case 'DJ':
          dialCode = '+253';
          break;
        case 'DM':
          dialCode = '+1767';
          break;
        case 'DO':
          dialCode = '+1809';
          break;
        case 'EC':
          dialCode = '+593';
          break;
        case 'EG':
          dialCode = '+20';
          break;
        case 'SV':
          dialCode = '+503';
          break;
        case 'GQ':
          dialCode = '+240';
          break;
        case 'ER':
          dialCode = '+291';
          break;
        case 'EE':
          dialCode = '+372';
          break;
        case 'ET':
          dialCode = '+251';
          break;
        case 'FK':
          dialCode = '+500';
          break;
        case 'FO':
          dialCode = '+298';
          break;
        case 'FJ':
          dialCode = '+679';
          break;
        case 'FI':
          dialCode = '+358';
          break;
        case 'GF':
          dialCode = '+594';
          break;
        case 'PF':
          dialCode = '+689';
          break;
        case 'GA':
          dialCode = '+241';
          break;
        case 'GM':
          dialCode = '+220';
          break;
        case 'GE':
          dialCode = '+995';
          break;
        case 'GH':
          dialCode = '+233';
          break;
        case 'GI':
          dialCode = '+350';
          break;
        case 'GE':
          dialCode = '+30';
          break;
        case 'GL':
          dialCode = '+299';
          break;
        case 'GD':
          dialCode = '+1437';
          break;
        case 'GP':
          dialCode = '+590';
          break;
        case 'GU':
          dialCode = '+1671';
          break;
        case 'GT':
          dialCode = '+502';
          break;
        case 'GN':
          dialCode = '+224';
          break;
        case 'GB':
          dialCode = '+245';
          break;
        case 'GY':
          dialCode = '+592';
          break;
        case 'HT':
          dialCode = '+509';
          break;
        case 'HN':
          dialCode = '+504';
          break;
        case 'HK':
          dialCode = '+852';
          break;
        case 'HU':
          dialCode = '+36';
          break;
        case 'IS':
          dialCode = '+354';
          break;
        case 'ID':
          dialCode = '+62';
          break;
        case 'IR':
          dialCode = '+98';
          break;
        case 'IQ':
          dialCode = '+964';
          break;
        case 'IE':
          dialCode = '+353';
          break;
        case 'IL':
          dialCode = '+972';
          break;
        case 'IT':
          dialCode = '+39';
          break;
        case 'JM':
          dialCode = '+1876';
          break;
        case 'JO':
          dialCode = '+962';
          break;
        case 'KZ':
          dialCode = '+7';
          break;
        case 'KE':
          dialCode = '+254';
          break;
        case 'KI':
          dialCode = '+686';
          break;
        case 'KP':
          dialCode = '+850';
          break;
        case 'KR':
          dialCode = '+82';
          break;
        case 'KW':
          dialCode = '+965';
          break;
        case 'KG':
          dialCode = '+996';
          break;
        case 'LA':
          dialCode = '+856';
          break;
        case 'LV':
          dialCode = '+371';
          break;
        case 'LB':
          dialCode = '+961';
          break;
        case 'LS':
          dialCode = '+266';
          break;
        case 'LR':
          dialCode = '+231';
          break;
        case 'LY':
          dialCode = '+218';
          break;
        case 'LI':
          dialCode = '+423';
          break;
        case 'LT':
          dialCode = '+370';
          break;
        case 'LU':
          dialCode = '+352';
          break;
        case 'MO':
          dialCode = '+853';
          break;
        case 'MK':
          dialCode = '+389';
          break;
        case 'MG':
          dialCode = '+261';
          break;
        case 'MW':
          dialCode = '+265';
          break;
        case 'MY':
          dialCode = '+60';
          break;
        case 'MV':
          dialCode = '+960';
          break;
        case 'ML':
          dialCode = '+223';
          break;
        case 'MT':
          dialCode = '+356';
          break;
        case 'MH':
          dialCode = '+692';
          break;
        case 'MQ':
          dialCode = '+596';
          break;
        case 'MR':
          dialCode = '+222';
          break;
        case 'MU':
          dialCode = '+230';
          break;
        case 'MX':
          dialCode = '+52';
          break;
        case 'FM':
          dialCode = '+691';
          break;
        case 'MD':
          dialCode = '+373';
          break;
        case 'MC':
          dialCode = '+377';
          break;
        case 'MN':
          dialCode = '+976';
          break;
        case 'ME':
          dialCode = '+382';
          break;
        case 'MS':
          dialCode = '+1664';
          break;
        case 'MA':
          dialCode = '+212';
          break;
        case 'MZ':
          dialCode = '+258';
          break;
        case 'MM':
          dialCode = '+95';
          break;
        case 'NA':
          dialCode = '+264';
          break;
        case 'NR':
          dialCode = '+674';
          break;
        case 'NP':
          dialCode = '+977';
          break;
        case 'NL':
          dialCode = '+31';
          break;
        case 'NC':
          dialCode = '+687';
          break;
        case 'NZ':
          dialCode = '+64';
          break;
        case 'NI':
          dialCode = '+505';
          break;
        case 'NE':
          dialCode = '+227';
          break;
        case 'NG':
          dialCode = '+234';
          break;
        case 'NF':
          dialCode = '+6723';
          break;
        case 'MP':
          dialCode = '+1670';
          break;
        case 'NO':
          dialCode = '+47';
          break;
        case 'OM':
          dialCode = '+968';
          break;
        case 'PK':
          dialCode = '+92';
          break;
        case 'PW':
          dialCode = '+680';
          break;
        case 'PS':
          dialCode = '+970';
          break;
        case 'PA':
          dialCode = '+507';
          break;
        case 'PG':
          dialCode = '+675';
          break;
        case 'PY':
          dialCode = '+595';
          break;
        case 'PE':
          dialCode = '+51';
          break;
        case 'PH':
          dialCode = '+63';
          break;
        case 'PL':
          dialCode = '+48';
          break;
        case 'PT':
          dialCode = '+351';
          break;
        case 'PR':
          dialCode = '+1787';
          break;
        case 'QA':
          dialCode = '+974';
          break;
        case 'RE':
          dialCode = '+262';
          break;
        case 'RO':
          dialCode = '+40';
          break;
        case 'RU':
          dialCode = '+7';
          break;
        case 'RW':
          dialCode = '+250';
          break;
        case 'BL':
          dialCode = '+590';
          break;
        case 'SH':
          dialCode = '+290';
          break;
        case 'KN':
          dialCode = '+1869';
          break;
        case 'LC':
          dialCode = '+1758';
          break;
        case 'MF':
          dialCode = '+590';
          break;
        case 'PM':
          dialCode = '+508';
          break;
        case 'VC':
          dialCode = '+1784';
          break;
        case 'WS':
          dialCode = '+685';
          break;
        case 'SM':
          dialCode = '+378';
          break;
        case 'ST':
          dialCode = '+239';
          break;
        case 'SA':
          dialCode = '+966';
          break;
        case 'SN':
          dialCode = '+221';
          break;
        case 'SC':
          dialCode = '+248';
          break;
        case 'SL':
          dialCode = '+232';
          break;
        case 'SG':
          dialCode = '+65';
          break;
        case 'SX':
          dialCode = '+1721';
          break;
        case 'SK':
          dialCode = '+421';
          break;
        case 'SI':
          dialCode = '+386';
          break;
        case 'SB':
          dialCode = '+677';
          break;
        case 'SO':
          dialCode = '+252';
          break;
        case 'SS':
          dialCode = '+211';
          break;
        case 'ES':
          dialCode = '+34';
          break;
        case 'LK':
          dialCode = '+94';
          break;
        case 'SD':
          dialCode = '+249';
          break;
        case 'SR':
          dialCode = '+597';
          break;
        case 'SZ':
          dialCode = '+268';
          break;
        case 'SE':
          dialCode = '+46';
          break;
        case 'CH':
          dialCode = '+41';
          break;
        case 'SY':
          dialCode = '+963';
          break;
        case 'TW':
          dialCode = '+886';
          break;
        case 'TJ':
          dialCode = '+992';
          break;
        case 'TZ':
          dialCode = '+255';
          break;
        case 'TH':
          dialCode = '+66';
          break;
        case 'TL':
          dialCode = '+670';
          break;
        case 'TG':
          dialCode = '+228';
          break;
        case 'TK':
          dialCode = '+690';
          break;
        case 'TO':
          dialCode = '+676';
          break;
        case 'TT':
          dialCode = '+1868';
          break;
        case 'TN':
          dialCode = '+216';
          break;
        case 'TR':
          dialCode = '+90';
          break;
        case 'TM':
          dialCode = '+993';
          break;
        case 'TC':
          dialCode = '+1649';
          break;
        case 'TV':
          dialCode = '+688';
          break;
        case 'UG':
          dialCode = '+256';
          break;
        case 'UA':
          dialCode = '+380';
          break;
        case 'AE':
          dialCode = '+971';
          break;
        case 'UY':
          dialCode = '+598';
          break;
        case 'UZ':
          dialCode = '+998';
          break;
        case 'VU':
          dialCode = '+678';
          break;
        case 'VA':
          dialCode = '+379';
          break;
        case 'VE':
          dialCode = '+58';
          break;
        case 'VN':
          dialCode = '+84';
          break;
        case 'VG':
          dialCode = '+1284';
          break;
        case 'VI':
          dialCode = '+1340';
          break;
        case 'WF':
          dialCode = '+681';
          break;
        case 'YE':
          dialCode = '+967';
          break;
        case 'ZM':
          dialCode = '+260';
          break;
        case 'ZW':
          dialCode = '+263';
          break;
      }
      return dialCode;
    }
    function getCountryDisplayCode(dialCode)
    {
          var countryCode = '';
          switch (dialCode)
          {
            case '+1':
              countryCode = 'US';
              break;
            case '+91':
              countryCode = 'IN';
              break;
            case '+44':
              countryCode = 'UK';
              break;
            case '+55':
              countryCode = 'BR';
              break;
            case '+33':
              countryCode = 'FR';
              break;
            case '+49':
              countryCode = 'DE';
              break;
            case '+81':
              countryCode = 'JP';
              break;
            case '+381':
              countryCode = 'CS';
              break;
            case '+27':
              countryCode = 'ZA';
              break;
            case '+93':
              countryCode = 'AF';
              break;
            case '+355':
              countryCode = 'AL';
              break;
            case '+213':
              countryCode = 'DZ';
              break;
            case '+1684':
              countryCode = 'AS';
              break;
            case '+376':
              countryCode = 'AD';
              break;
            case '+244':
              countryCode = 'AO';
              break;
            case '+1264':
              countryCode = 'AI';
              break;
            case '+1268':
              countryCode = 'AG';
              break;
            case '+54':
              countryCode = 'AR';
              break;
            case '+374':
              countryCode = 'AM';
              break;
            case '+297':
              countryCode = 'AW';
              break;
            case '+247':
              countryCode = 'AC';
              break;
            case '+61':
              countryCode = 'AU';
              break;
            case '+43':
              countryCode = 'AT';
              break;
            case '+994':
              countryCode = 'AZ';
              break;
            case '+1242':
              countryCode = 'BS';
              break;
            case '+973':
              countryCode = 'BH';
              break;
            case '+880':
              countryCode = 'BD';
              break;
            case '+1246':
              countryCode = 'BB';
              break;
            case '+375':
              countryCode = 'BY';
              break;
            case '+32':
              countryCode = 'BE';
              break;
            case '+501':
              countryCode = 'BZ';
              break;
            case '+229':
              countryCode = 'BJ';
              break;
            case '+1441':
              countryCode = 'BM';
              break;
            case '+975':
              countryCode = 'BT';
              break;
            case '+591':
              countryCode = 'BO';
              break;
            case '+599':
              countryCode = 'BQ';
              break;
            case '+387':
              countryCode = 'BA';
              break;
            case '+267':
              countryCode = 'BW';
              break;
            case '+673':
              countryCode = 'BN';
              break;
            case '+359':
              countryCode = 'BG';
              break;
            case '+226':
              countryCode = 'BF';
              break;
            case '+257':
              countryCode = 'BI';
              break;
            case '+855':
              countryCode = 'KH';
              break;
            case '+237':
              countryCode = 'CM';
              break;
            case '+1':
              countryCode = 'CA';
              break;
            case '+238':
              countryCode = 'CV';
              break;
            case '+1345':
              countryCode = 'KY';
              break;
            case '+236':
              countryCode = 'CF';
              break;
            case '+235':
              countryCode = 'TD';
              break;
            case '+56':
              countryCode = 'CL';
              break;
            case '+86':
              countryCode = 'CN';
              break;
            case '+57':
              countryCode = 'CO';
              break;
            case '+269':
              countryCode = 'KM';
              break;
            case '+242':
              countryCode = 'CG';
              break;
            case '+243':
              countryCode = 'CD';
              break;
            case '+682':
              countryCode = 'CK';
              break;
            case '+506':
              countryCode = 'CR';
              break;
            case '+225':
              countryCode = 'CI';
              break;
            case '+385':
              countryCode = 'HR';
              break;
            case '+53':
              countryCode = 'CU';
              break;
            case '+599':
              countryCode = 'CW';
              break;
            case '+357':
              countryCode = 'CY';
              break;
            case '+420':
              countryCode = 'CZ';
              break;
            case '+45':
              countryCode = 'DK';
              break;
            case '+246':
              countryCode = 'DG';
              break;
            case '+253':
              countryCode = 'DJ';
              break;
            case '+1767':
              countryCode = 'DM';
              break;
            case '+1809':
              countryCode = 'DO';
              break;
            case '+593':
              countryCode = 'EC';
              break;
            case '+20':
              countryCode = 'EG';
              break;
            case '+503':
              countryCode = 'SV';
              break;
            case '+240':
              countryCode = 'GQ';
              break;
            case '+291':
              countryCode = 'ER';
              break;
            case '+372':
              countryCode = 'EE';
              break;
            case '+251':
              countryCode = 'ET';
              break;
            case '+500':
              countryCode = 'FK';
              break;
            case '+298':
              countryCode = 'FO';
              break;
            case '+679':
              countryCode = 'FJ';
              break;
            case '+358':
              countryCode = 'FI';
              break;
            case '+594':
              countryCode = 'GF';
              break;
            case '+689':
              countryCode = 'PF';
              break;
            case '+241':
              countryCode = 'GA';
              break;
            case '+220':
              countryCode = 'GM';
              break;
            case '+995':
              countryCode = 'GE';
              break;
            case '+233':
              countryCode = 'GH';
              break;
            case '+350':
              countryCode = 'GI';
              break;
            case '+30':
              countryCode = 'GE';
              break;
            case '+299':
              countryCode = 'GL';
              break;
            case '+1473':
              countryCode = 'GD';
              break;
            case '+590':
              countryCode = 'GP';
              break;
            case '+1671':
              countryCode = 'GU';
              break;
            case '+502':
              countryCode = 'GT';
              break;
            case '+224':
              countryCode = 'GN';
              break;
            case '+245':
              countryCode = 'GB';
              break;
            case '+592':
              countryCode = 'GY';
              break;
            case '+509':
              countryCode = 'HT';
              break;
            case '+504':
              countryCode = 'HN';
              break;
            case '+852':
              countryCode = 'HK';
              break;
            case '+36':
              countryCode = 'HU';
              break;
            case '+354':
              countryCode = 'IS';
              break;
            case '+62':
               countryCode = 'ID';
               break;           
            case '+98':
               countryCode = 'IR';
               break;           
            case '+964':
               countryCode = 'IQ';
               break;           
            case '+353':
               countryCode = 'IE';
               break;           
            case '+972':
               countryCode = 'IL';
               break;           
            case '+39':
               countryCode = 'IT';
               break;           
            case '+1876':
               countryCode = 'JM';
               break;           
            case '+962':
               countryCode = 'JO';
               break;           
            case '+7':
               countryCode = 'KZ';
               break;           
            case '+254':
               countryCode = 'KE';
               break;           
            case '+686':
               countryCode = 'KI';
               break;           
            case '+850':
               countryCode = 'KP';
               break;           
            case '+82':
               countryCode = 'KR';
               break;           
            case '+965':
               countryCode = 'KW';
               break;           
            case '+996':
               countryCode = 'KG';
               break;           
            case '+856':
               countryCode = 'LA';
               break;           
            case '+371':
               countryCode = 'LV';
               break;           
            case '+961':
               countryCode = 'LB';
               break;           
            case '+266':
               countryCode = 'LS';
               break;           
            case '+231':
               countryCode = 'LR';
               break;           
            case '+218':
               countryCode = 'LY';
               break;           
            case '+423':
               countryCode = 'LI';
               break;           
            case '+370':
               countryCode = 'LT';
               break;           
            case '+352':
               countryCode = 'LU';
               break;           
            case '+853':
               countryCode = 'MO';
               break;           
            case '+389':
               countryCode = 'MK';
               break;           
            case '+261':
               countryCode = 'MG';
               break;           
            case '+265':
               countryCode = 'MW';
               break;           
            case '+60':
               countryCode = 'MY';
               break;           
            case '+960':
               countryCode = 'MV';
               break;           
            case '+223':
               countryCode = 'ML';
               break;           
            case '+356':
               countryCode = 'MT';
               break;           
            case '+692':
               countryCode = 'MH';
               break;           
            case '+596':
               countryCode = 'MQ';
               break;           
            case '+222':
               countryCode = 'MR';
               break;           
            case '+230':
               countryCode = 'MU';
               break;           
            case '+52':
               countryCode = 'MX';
               break;           
            case '+691':
               countryCode = 'FM';
               break;           
            case '+373':
               countryCode = 'MD';
               break;           
            case '+377':
               countryCode = 'MC';
               break;           
            case '+976':
               countryCode = 'MN';
               break;           
            case '+382':
               countryCode = 'ME';
               break;           
            case '+1664':
               countryCode = 'MS';
               break;           
            case '+212':
               countryCode = 'MA';
               break;           
            case '+258':
               countryCode = 'MZ';
               break;           
            case '+95':
               countryCode = 'MM';
               break;           
            case '+264':
               countryCode = 'NA';
               break;           
            case '+674':
               countryCode = 'NR';
               break;           
            case '+977':
               countryCode = 'NP';
               break;           
            case '+31':
               countryCode = 'NL';
               break;           
            case '+687':
               countryCode = 'NC';
               break;           
            case '+64':
               countryCode = 'NZ';
               break;           
            case '+505':
               countryCode = 'NI';
               break;
            case '+227':
               countryCode = 'NE';
               break;
            case '+234':
               countryCode = 'NG';
               break;
            case '+6723':
               countryCode = 'NF';
               break;
            case '+1670':
               countryCode = 'MP';
               break;
            case '+47':
               countryCode = 'NO';
               break;
            case '+968':
               countryCode = 'OM';
               break;
            case '+92':
               countryCode = 'PK';
               break;
            case '+680':
               countryCode = 'PW';
               break;
            case '+970':
               countryCode = 'PS';
               break;
            case '+507':
               countryCode = 'PA';
               break;
            case '+675':
               countryCode = 'PG';
               break;
            case '+595':
               countryCode = 'PY';
               break;
            case '+51':
               countryCode = 'PE';
               break;
            case '+63':
               countryCode = 'PH';
               break;
            case '+48':
               countryCode = 'PL';
               break;
            case '+351':
               countryCode = 'PT';
               break;
            case '+1787':
               countryCode = 'PR';
               break;
            case '+974':
               countryCode = 'QA';
               break;
            case '+262':
               countryCode = 'RE';
               break;
            case '+40':
               countryCode = 'RO';
               break;
            case '+7':
               countryCode = 'RU';
               break;
            case '+250':
               countryCode = 'RW';
               break;
            case '+590':
               countryCode = 'BL';
               break;
            case '+290':
               countryCode = 'SH';
               break;
            case '+1869':
               countryCode = 'KN';
               break;
            case '+1758':
               countryCode = 'LC';
               break;
            case '+590':
               countryCode = 'MF';
               break;
            case '+508':
               countryCode = 'PM';
               break;
            case '+1784':
               countryCode = 'VC';
               break;
            case '+685':
               countryCode = 'WS';
               break;
            case '+378':
               countryCode = 'SM';
               break;
            case '+239':
               countryCode = 'ST';
               break;
            case '+966':
               countryCode = 'SA';
               break;
            case '+221':
               countryCode = 'SN';
               break;
            case '+248':
               countryCode = 'SC';
               break;
            case '+232':
               countryCode = 'SL';
               break;
            case '+65':
               countryCode = 'SG';
               break;
            case '+1721':
               countryCode = 'SX';
               break;
            case '+421':
               countryCode = 'SK';
               break;
            case '+386':
               countryCode = 'SI';
               break;
            case '+677':
               countryCode = 'SB';
               break;
            case '+252':
               countryCode = 'SO';
               break;
            case '+211':
               countryCode = 'SS';
               break;
            case '+34':
               countryCode = 'ES';
               break;
            case '+94':
               countryCode = 'LK';
               break;
            case '+249':
               countryCode = 'SD';
               break;
            case '+597':
               countryCode = 'SR';
               break;
            case '+268':
               countryCode = 'SZ';
               break;
            case '+46':
               countryCode = 'SE';
               break;
            case '+41':
               countryCode = 'CH';
               break;
            case '+963':
               countryCode = 'SY';
               break;
            case '+886':
               countryCode = 'TW';
               break;
            case '+992':
               countryCode = 'TJ';
               break;
            case '+255':
               countryCode = 'TZ';
               break;
            case '+66':
               countryCode = 'TH';
               break;
            case '+670':
               countryCode = 'TL';
               break;
            case '+228':
               countryCode = 'TG';
               break;
            case '+690':
               countryCode = 'TK';
               break;
            case '+676':
               countryCode = 'TO';
               break;
            case '+1868':
               countryCode = 'TT';
               break;
            case '+216':
               countryCode = 'TN';
               break;
            case '+90':
               countryCode = 'TR';
               break;
            case '+993':
               countryCode = 'TM';
               break;
            case '+1649':
               countryCode = 'TC';
               break;
            case '+688':
               countryCode = 'TV';
               break;
            case '+256':
               countryCode = 'UG';
               break;
            case '+380':
               countryCode = 'UA';
               break;
            case '+971':
               countryCode = 'AE';
               break;
            case '+598':
               countryCode = 'UY';
               break;
            case '+998':
               countryCode = 'UZ';
               break;
            case '+678':
               countryCode = 'VU';
               break;
            case '+379':
               countryCode = 'VA';
               break;
            case '+58':
               countryCode = 'VE';
               break;
            case '+84':
               countryCode = 'VN';
               break;
            case '+1284':
               countryCode = 'VG';
               break;
            case '+1340':
               countryCode = 'VI';
               break;
            case '+681':
               countryCode = 'WF';
               break;
            case '+967':
               countryCode = 'YE';
               break;
            case '+260':
               countryCode = 'ZM';
               break;
            case '+263':
               countryCode = 'ZW';
               break;               
          }
          return countryCode;
     }
    function PhoneValidation(flagNum, message)
    {
        this.flagNum  = flagNum;
        this.message = message;
    }
    function validatePhoneNum(dialCode, phoneNum)
    {
        //var flagNum = true;  
        var pValidation = new PhoneValidation(true, ''); //defualt for +43, +49 +964 +39
        //alert('dialCode : '+dialCode);
        phoneNum = getCleanNumber(phoneNum);
        switch (dialCode)
        {
            case '+1': case '+91': case '+54': case '+44': case '+30': case '+98': case '+7': case '+58':
            case '+90': case '+52': case '+378':                            
              if (phoneNum.length != 10) {pValidation.flagNum = false;  pValidation.message = 'Invalid Number: '+phoneNum+'\nPlease provide a 10 digit number';}
              break;
            case '+93': case '+244': case '+61': case '+994': case '+375': case '+242': case '+420': case '+240':
            case '+251': case '+33': case '+594': case '+995': case '+233': case '+590': case '+996': case '+260':
            case '+256': case '+380': case '+998': case '+992': case '+255': case '+250': case '+40': case '+262':
            case '+351': case '+48': case '+595': case '+31': case '+212': case '+596': case '+261': case '+221':
            case '+421': case '+27': case '+211': case '+34': case '+94': case '+249': case '+41':
              if (phoneNum.length != 9) {pValidation.flagNum = false;  pValidation.message = 'Invalid Number: '+phoneNum+'\nPlease provide a 9 digit number';}
              break;              
            case '+355': case '+374': case '+973': case '+229': case '+591': case '+387': case '+226': case '+257':
            case '+237': case '+236': case '+235': case '+506': case '+225': case '+599': case '+357': case '+45':
            case '+253': case '+503': case '+350': case '+502': case '+224': case '+509': case '+504': case '+852':
            case '+965': case '+371': case '+266': case '+370': case '+598': case '+228': case '+216': case '+993':
            case '+968': case '+974': case '+47': case '+227': case '+505': case '+382': case '+373': case '+222':
            case '+356': case '+223': case '+853': case '+389': case '+232': case '+65': case '+386':
            case '+268':
              if (phoneNum.length != 8) {pValidation.flagNum = false;  pValidation.message = 'Invalid Number: '+phoneNum+'\nPlease provide a 8 digit number';}
              break;              
            case '+1268': case '+1684': case '+1264': case '+297': case '+1242': case '+1246': case '+501':
            case '+1441': case '+1284': case '+673': case '+238': case '+1345': case '+269': case '+246':
            case '+1767': case '+1809': case '+291': case '+372': case '+679': case '+220': case '+1473':
            case '+1671': case '+245': case '+592': case '+1876': case '+423': case '+1340': case '+1868':
            case '+1649': case '+1787': case '+680': case '+1670': case '+674': case '+1664':
            case '+691': case '+230': case '+692': case '+960': case '+1869': case '+1758': case '+1784':
            case '+239': case '+248': case '+1721':
              if (phoneNum.length != 7) {pValidation.flagNum = false;  pValidation.message = 'Invalid Number: '+phoneNum+'\nPlease provide a 7 digit number';}
              break;                                  
            case '+376': case '+298': case '+689': case '+299': case '+681': case '+687': case '+508':
              if (phoneNum.length != 6) {pValidation.flagNum = false;  pValidation.message = 'Invalid Number: '+phoneNum+'\nPlease provide a 6 digit number';}
              break;
            case '+682': case '+500': case '+686': case '+676': case '+688': case '+6723': 
              if (phoneNum.length != 5) {pValidation.flagNum = false;  pValidation.message = 'Invalid Number: '+phoneNum+'\nPlease provide a 5 digit number';}
              break;              
            case '+247': case '+690': case '+683': case '+290':
              if (phoneNum.length != 4) {pValidation.flagNum = false;  pValidation.message = 'Invalid Number: '+phoneNum+'\nPlease provide a 4 digit number';}
              break;              
            case '+352': 
              if (phoneNum.length < 5 && phoneNum.length > 11) {pValidation.flagNum = false;  pValidation.message = 'Invalid Number: '+phoneNum+'\nPlease provide a valid phone number';}
              break;              
            case '+358': 
              if (phoneNum.length < 5 && phoneNum.length > 12) {pValidation.flagNum = false;  pValidation.message = 'Invalid Number: '+phoneNum+'\nPlease provide a valid phone number';}
              break;
            case '+677': case '+678': case '+685':
              if (phoneNum.length != 5 && phoneNum.length != 7) {pValidation.flagNum = false;  pValidation.message = 'Invalid Number: '+phoneNum+'\nPlease provide a 5 or 7 digit phone number';}
              break;                          
            case '+53': 
              if (phoneNum.length < 6 && phoneNum.length > 8) {pValidation.flagNum = false;  pValidation.message = 'Invalid Number: '+phoneNum+'\nPlease provide a valid phone number';}
              break;
            case '+597':
              if (phoneNum.length != 6 && phoneNum.length != 7) {pValidation.flagNum = false;  pValidation.message = 'Invalid Number: '+phoneNum+'\nPlease provide a 6 or 7 digit number';}
              break;                          
            case '+241':
              if (phoneNum.length != 6 && phoneNum.length != 8) {pValidation.flagNum = false;  pValidation.message = 'Invalid Number: '+phoneNum+'\nPlease provide a 6 or 8 digit number';}
              break;                          
            case '+975': case '+267': case '+961': case '+231': case '+670': case '+507': case '+675': case '+976':
            case '+95': case '+252':
              if (phoneNum.length != 8 && phoneNum.length != 7) {pValidation.flagNum = false;  pValidation.message = 'Invalid Number: '+phoneNum+'\nPlease provide a 7 or 8 digit number';}
              break;
            case '+971': case '+886': case '+66': case '+264': case '+258': case '+377': case '+46': case '+963': case '+966':
              if (phoneNum.length != 8 && phoneNum.length != 9) {pValidation.flagNum = false;  pValidation.message = 'Invalid Number: '+phoneNum+'\nPlease provide a 8 or 9 digit number';}
              break;
            case '+234': 
              if (phoneNum.length != 7 && phoneNum.length != 8 && phoneNum.length != 10) {pValidation.flagNum = false;  pValidation.message = 'Invalid Number: '+phoneNum+'\nPlease provide a 7 or 8 or 10 digit number';}
              break;                          
            case '+243': case '+354': case '+265':
              if (phoneNum.length != 7 && phoneNum.length != 9) {pValidation.flagNum = false;  pValidation.message = 'Invalid Number: '+phoneNum+'\nPlease provide a 7 or 9 digit number';}
              break;              
            case '+359': case '+353': case '+254': case '+263': case '+967': case '+381':
              if (phoneNum.length < 7 && phoneNum.length > 9) {pValidation.flagNum = false;  pValidation.message = 'Invalid Number: '+phoneNum+'\nPlease provide a valid phone number';}
              break;                              
            case '+880': case '+218': case '+84': 
              if (phoneNum.length < 7 && phoneNum.length > 10) {pValidation.flagNum = false;  pValidation.message = 'Invalid Number: '+phoneNum+'\nPlease provide a valid phone number';}
              break;
            case '+62': 
              if (phoneNum.length < 7 && phoneNum.length > 11) {pValidation.flagNum = false;  pValidation.message = 'Invalid Number: '+phoneNum+'\nPlease provide a valid phone number';}
              break;              
            case '+213': case '+32': case '+855': case '+56': case '+385': case '+593': case '+36': case '+972': case '+962':
            case '+850': case '+970': case '+51': 
              if (phoneNum.length != 8 && phoneNum.length != 9) {pValidation.flagNum = false;  pValidation.message = 'Invalid Number: '+phoneNum+'\nPlease provide a 8 or 9 digit number';}
              break;
            case '+57': case '+856': case '+977':                                   
              if (phoneNum.length != 8 && phoneNum.length != 10) {pValidation.flagNum = false;  pValidation.message = 'Invalid Number: '+phoneNum+'\nPlease provide a 8 or 10 digit number';}
              break;
            case '+20': case '+63': case '+64': case '+60':
              if (phoneNum.length < 8 && phoneNum.length > 10) {pValidation.flagNum = false;  pValidation.message = 'Invalid Number: '+phoneNum+'\nPlease provide a valid phone number';}
              break;
            case '+81': case '+379': case '+92':                                    
              if (phoneNum.length != 9 && phoneNum.length != 10) {pValidation.flagNum = false;  pValidation.message = 'Invalid Number: '+phoneNum+'\nPlease provide a 9 or 10 digit number';}
              break;                                                              
            case '+55':                                     
              if (phoneNum.length != 10 && phoneNum.length != 11) {pValidation.flagNum = false;  pValidation.message = 'Invalid Number: '+phoneNum+'\nPlease provide a 10 or 11 digit number';}
              break;
            case '+86': 
              if (phoneNum.length < 8 && phoneNum.length > 12) {pValidation.flagNum = false;  pValidation.message = 'Invalid Number: '+phoneNum+'\nPlease provide a valid phone number';}
              break;
            case '+82': 
              if (phoneNum.length < 6 && phoneNum.length > 12) {pValidation.flagNum = false;  pValidation.message = 'Invalid Number: '+phoneNum+'\nPlease provide a valid phone number';}
              break;                                                                       
        }
          //alert('flagNum : '+flagNum);
          return pValidation;
    }

   //Utility to clean up the phone number
   function getCleanNumber(number)
   {
       number = number.replace(/\s/g,'');
       number = number.replace(/[abc ABC]/g,'2');
       number = number.replace(/[def DEF]/g,'3');
       number = number.replace(/[ghi GHI]/g,'4');
       number = number.replace(/[jkl JKL]/g,'5');
       number = number.replace(/[mno MNO]/g,'6');
       number = number.replace(/[pqrs PQRS]/g,'7');
       number = number.replace(/[tuv TUV]/g,'8');
       number = number.replace(/[wxyz WXYZ]/g,'9');
       number = number.replace(/[^0-9]/g,'');

	   if (number.startsWith("00")) {
	     number = number.replace("00", "");
	   }
	   if (number.startsWith("0")) {
	     number = number.replace("0", "");
	   }
	   
       //if(number.length == 10)
       //number = '1'+number;
       //number = getCleanCode(selectedCountryCode) + number;
       return number;
   }
 
     //Generate UUID
    function generateUUID() 
    {
       var s = [], itoh = '0123456789ABCDEF';
       for (var i = 0; i <36; i++) s[i] = Math.floor(Math.random()*0x10);
       s[14] = 4;  // Set 4 high bits of time_high field to version
       s[19] = (s[19] & 0x3) | 0x8;  // Specify 2 high bits of clock sequence
       for (var i = 0; i <36; i++) s[i] = itoh[s[i]];
       s[8] = s[13] = s[18] = s[23] = '-';
       return s.join('');
    }

	//function to printout the properties of an object    
    function printObject(o) {
      var out = '';
      for (var p in o) {
        out += p + ': ' + o[p] + '\n';
      }
      alert(out);
    }

function cancelBubble(e) {
 var evt = e ? e:window.event;
 if (evt.stopPropagation)    evt.stopPropagation();
 if (evt.cancelBubble!=null) evt.cancelBubble = true;
}

    function showCallSetup () {
      var dialog = document.getElementById('setup');
      if (!dialog.open) {
        var content = document.getElementById('setupContent');
        content.innerText = 'Connecting..' + localStorage.getItem(CALL_NUMBER);
        dialog.showModal();
      }
      dialog = document.getElementById('inprogress');
      if (dialog.open) {
        dialog.close();
      }
      dialog = document.getElementById('complete');
      if (dialog.open) {
        dialog.close();
      }
    }

    function resetCallComplete() {
      dialog = document.getElementById('complete');
      if (dialog.open) {
        dialog.close();
      }
    }

    function closeCallReset() {
      dialog = document.getElementById('callreset');
      if (dialog.open) {
        dialog.close();
      }
    }

    function showCallReset() {
      dialog = document.getElementById('callreset');
      if (!dialog.open) {
        dialog.showModal();
      }
    }

    function showCallCompelete () {
      var dialog = document.getElementById('setup');
      if (dialog.open) {
       dialog.close();
      }
      dialog = document.getElementById('inprogress');
      if (dialog.open) {
        dialog.close();
      }
      dialog = document.getElementById('complete');
      if (!dialog.open) {
        var content = document.getElementById('completeContent');
        content.innerText = 'Call Complete: ' + localStorage.getItem(CALL_NUMBER);
        dialog.showModal();
      }
    }

    function showCallInprogress () {
      var dialog = document.getElementById('setup');
      if (dialog.open) {
       dialog.close();
      }
      dialog = document.getElementById('inprogress');
      if (!dialog.open) {
        var content = document.getElementById('inprogressContent');
        content.innerText = 'On Call..' + localStorage.getItem(CALL_NUMBER);
        dialog.showModal();
      }
      dialog = document.getElementById('complete');
      if (dialog.open) {
        dialog.close();
      }
    }

    function showError (error) {

      var dialog = document.getElementById('setup');
      if (dialog.open) {
       dialog.close();
      }

      dialog = document.getElementById('inprogress');
      if (dialog.open) {
       dialog.close();
      }

      dialog = document.getElementById('callerror');
      if (!dialog.open) {
        var content = document.getElementById('errorContent');
        content.innerText = error;
        dialog.showModal();
      }
    }

    //Parse the Error Message from CTI Response and prepare to show
    function showErroeMessageFromClick2Dial(errorMsgObj) {

      var erroeMessage = "Call failed; please try again.";
      var flagSpl = false;
      notAnErrorCon = false;
      var showLogCall = false;

      if (typeof errorMsgObj == "object" && errorMsgObj != null) {
        var errorCode = errorMsgObj.errorCode; //.error_code
        if (errorCode) {
          errorCode = errorCode.trim();
        } else {
          erroeMessage = errorMsgObj.message;

          if (erroeMessage == "Invalid Credentials") {
            erroeMessage = "Your Google login has expired. Please login in to your Google account.";
          }
        }
                 
        if (errorCode == "AGENT_PHONE_INVALID") {
          erroeMessage = "We cannot connect to your phone. Please check the extension under your User Details page.";
        } else if (errorCode == "MISSING_REQUIRED_FIELDS") {
          erroeMessage = "User Details may be missing information required to connect to your phone.  Please check the extension, PBX Site or category fields under your User Details page.";
        } else if (errorCode == "CALL_NOT_FOUND") {
          erroeMessage = "There was a connection issue and we lost the status of your call.  Please log your call manually or try calling again.";
        } else if (errorCode == "CALL_NOT_ANSWERED") {
          erroeMessage = "Your call is not being answered.  Please try again later.";
        } else if (errorCode == "SITE_NOT_FOUND" || errorCode == "TLINK_NOT_FOUND" || errorCode == "LVI_NOT_FOUND" || errorCode == "RPC_FAIL" || errorCode == "AES_CONNECTION_FAIL" || errorCode == "INVALID_SITE" || errorCode == "INVALID_TLINKS" || errorCode == "CTI_CALL_FAIL") {
          erroeMessage = "We cannot connect to your phone.  Please check that PBX Site is correct under your User Details page.";
        } else if (errorCode == "AGENT_NO_ANSWER" || errorCode == "AGENT_BUSY") {
          erroeMessage = "Weâ€™re experiencing difficulty connecting to your phone.  Please check that your phone is receiving calls.";
        } else if (errorCode == "CUSTOMER_NO_ANSWER") {
          erroeMessage = "The phone number you called is not answering.  Please check the phone number and try again.";
        } else if (errorCode == "CUSTOMER_PHONE_INVALID") {
          erroeMessage = "We cannot connect the number you dialed. Please check the phone number and try again.";
        } else if (errorCode == "AGENT_CALL_FAIL") {
          erroeMessage = "Your call cannot be connected. Please check your number and try again."; //The call was disconnected.  Please try again.
        } else if (errorCode == "CUSTOMER_CALL_FAIL") {
          erroeMessage = "Your call cannot be connected. Please check your number and try again."; //The call was disconnected.  Please try again.
        } else if (errorCode == "CUSTOMER_BUSY") {
          erroeMessage = "The phone number you called is busy.  Please try again later.";
        } else if (errorCode == "AUTHENTICATION_TYPE_INVALID") {
          erroeMessage = "We could not authenticate you because your authentication ID Type is not supported by Apiary.  Please submit a support ticket at goto/ccrequest with this error message.";
        } else if (errorCode == "AUTHENTICATION_NO_AUTHENTICATED_USER") {
          erroeMessage = "Your Click2Dial authentication has timed out.  Please refresh the Salesforce page and try again.";
        } else if (errorCode == "AUTHENTICATION_USER_UNAUTHORIZED") {
          erroeMessage = "Oops...you are not logged in to the Google network.  Please confirm your connection to the network and try again.";
        } else if (errorCode == "AUTHENTICATION_FAIL") {                     
          if (errorMsgObj.hasOwnProperty("message") && errorMsgObj.message != '' && errorMsgObj.message) {
            erroeMessage = errorMsgObj.message + ". If you are connected from a Google network and problem persists, please submit a support ticket at goto/ccrequest.";
          } else {
            erroeMessage = "We could not connect to the server for your authentication. If you are connected from a Google network and problem persists, please submit a support ticket at goto/ccrequest.";
          }
        }
        showError (erroeMessage);
        paramString = "&ani=" + localStorage.getItem(CALL_NUMBER) + "&objectId=" + localStorage.getItem(CALL_ID)  + "&callId=" + localStorage.getItem(CALL_UUID)+ "&error=" + errorCode;
        sforce.interaction.runApex('CreateCaseWS', 'createErrorAuditOutbound', paramString, null);		
      }
   }
    function clickToDial(phoneNum, countryCode, id) {

       localStorage.setItem(CALL_NUMBER, phoneNum);
       localStorage.setItem(CALL_ID, id);

       if (id != '') {
         sforce.interaction.screenPop('/' + id, true, null);
       }
       var selectedCountryCode;
	   retryNumber = '';

       if (phoneNum.charAt(0) == '+') {

           phoneNum = checkNumFormat(phoneNum);
           var charPos = getFirstOccuranceOfHyphenOrSpace(phoneNum);
           var tempPNum = '';
          if(charPos < 0) {

              var cCodesRes = getSeparatedCountryCode(phoneNum);
              selectedCountryCode = cCodesRes.isdCode;
              selectedDisplayCode = cCodesRes.dispCode;
              tempPNum = phoneNum.substring(selectedCountryCode.length, phoneNum.length);
          
           } else if (charPos > 0)  {

              if(charPos < 2 || charPos > 5) {
                return;
              }
            Â  var dialCode = phoneNum.substring(0, charPos);
            Â  tempPNum = phoneNum.substring(charPos+1, phoneNum.length); 
                         
              selectedDisplayCode =  getCountryDisplayCode(dialCode);
              selectedCountryCode = dialCode;        
           }
              
           if(selectedCountryCode == '' || selectedDisplayCode == '') {
             return;             
           }  
           if (tempPNum == '') {

             return;          
           }  
           /*var pValidationRes =  validatePhoneNum(selectedCountryCode, tempPNum);       
           if(!pValidationRes.flagNum) {   
             alert(pValidationRes.message);		   
             return;            
           }   */                    
       } //end...
       else {          
          var tempPNum = getCleanNumber(phoneNum);
          selectedCountryCode = getDefualtDialCode(countryCode);
          /*var pValidationRes =  validatePhoneNum(selectedCountryCode, tempPNum);       
          if(!pValidationRes.flagNum) {      
            alert(pValidationRes.message);
            return;            
          } */
          if(selectedCountryCode == '') {

            alert('Your settings contains an invalid country code that cannot be used for outbound dialing.  Please correct the country code on the User Detail page or Contact Sys Admin for assistance.');             
            return;
          }
		  /* IF phone number Starts with Country code replace country code */
		  selectedCountryCode1 = selectedCountryCode.replace("+", "");
		  if (tempPNum.startsWith(selectedCountryCode1)) {
 		    retryNumber = tempPNum;
		    tempPNum = tempPNum.replace(selectedCountryCode1, "");
		  }  
          phoneNum = selectedCountryCode + tempPNum;     
       }
       performOutboundCall(getCleanNumber(phoneNum), selectedCountryCode, retryNumber);
    }

    //CallbackHandler for Click
    function clickToDialCallback(response) {

      sforce.interaction.setVisible(true);
      var result = JSON.parse(response.result);
      clickToDial(result.number, country, result.objectId);
    }

   function resetCTI() {
     localStorage.removeItem(CALL_UUID);
     closeCallReset();
   }

   function screenPop(phoneNum, id) {
       if (id != '') {
         sforce.interaction.screenPop('/' + id, true, null);
       } else {
         sforce.interaction.searchAndScreenPop(phoneNum, '', 'inbound', null);
       }
    }

	    function loadPhoneHover () {
        $(".callresult tr").click(function() {
          $(this).find(".phonelink")[0].onclick();
        });
        $(".callresult tr").hover(
          function () {
            $(this).css("background","#eee");
            $(this).find('.phoneiconshow').removeClass('phoneiconhide');
          }, 
          function () {
            $(this).css("background","");
            $(this).find('.phoneiconshow').addClass('phoneiconhide');
          }
        );
    }

    function keepTrackOfTheCall() {  

      var request = gapi.client.request({
          'root': googleC2DApiUrl,
           'path': 'click2dial/v1/outboundcalls/'+callUUID,
           'method': 'GET'
      }); 
        
      request.execute(function (response) {

        var state = response.result;

        if (state == "CALL_SETUP") {
          showCallSetup();
          setTimeout("keepTrackOfTheCall()", 2000);            
        } else if(state == "CALL_INPROGRESS") {
           showCallInprogress();
           setTimeout("keepTrackOfTheCall()", 2000);
           return;                    
        } else if (state == "CALL_COMPLETED") {
          showCallCompelete();
          paramString = "&ani=" + localStorage.getItem(CALL_NUMBER) + "&objectId=" + localStorage.getItem(CALL_ID)  + "&callId=" + localStorage.getItem(CALL_UUID) + "&startTime=" + response.startTime +"&endTime=" + response.stopTime;
          sforce.interaction.runApex('CreateCaseWS', 'createAuditOutbound', paramString, null);
          localStorage.removeItem(CALL_UUID);
          setTimeout("resetCallComplete()", 3000);
          return;                     
        } else {
          showErroeMessageFromClick2Dial(response.error);
          localStorage.removeItem(CALL_UUID);
          return;
        }
      });
    }

		var callback = function (response) {
		if (response.result) {
           $('.countryDropdown').css("width", "220px");
		}
	};
    Sfdc.onReady(function() {
      setTimeout(auth,1000);
      document.getElementById('exitError').onclick = function() {
        var dialog = document.getElementById('callerror');
        dialog.close();
      };
if (navigator.userAgent.indexOf('Mac OS X') != -1) {
  $('.searchinput').attr('size', 18);
}  else {
    $('.searchinput').attr('size', 14);
}
$(".countryimg").select2({
  formatResult: formatCountry,
  formatSelection: formatCountrySelection,
    escapeMarkup: function(m) { return m; },
    dropdownAutoWidth:true,
    containerCssClass:'countryContainer',
    dropdownCssClass:'countryDropdown'
});
      sforce.interaction.isInConsole(callback);
loadPhoneHover();

    });