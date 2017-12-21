(function($){

	var sleepFor = function (sleepDuration)
	{
	    var now = new Date().getTime();
	    while(new Date().getTime() < now + sleepDuration){ /* do nothing */ } 
	}

	var checkSingleTab = function ()
	{
		if(localStorage.JarvisMontreMoi != timeToken)
		{
			console.log("Already open (" + localStorage.JarvisMontreMoi + "ms/" + timeToken +")");
			$("#montre-moi").hide();
			$("#montre-moi-error").show();
			window.close();
			throw "Jarvis was open in another tab";
		}
	}

	var initScript = function ()
	{
		localStorage.JarvisMontreMoi = timeToken;
		sleepFor(Math.floor((Math.random() * 200)));

		checkSingleTab();
		console.log("This Jarvis won..." + timeToken);
		setInterval(checkSingleTab, 1000);

		updateStatus();
		if(botFace.length > 0)
		{
			$("#display #main-image").show();
		}
		else
		{
			$("#display #bot").show();
		}

		$("#display").css('height', 'auto');

		if(useQwant)
		{
			$('#engine-logo').attr('src', "https://about.qwant.com/wp-content/themes/qwomcenter/images/qwantLogo-x1.png");
		}
		else
		{
			$('#engine-logo').attr('src', "https://www.google.fr/images/branding/googlelogo/2x/googlelogo_color_120x44dp.png");			
		}
		
		
	}

	var initConnection = function (webSocketServer)
	{
		var ws = new WebSocket(webSocketServer);

		ws.onopen = function() {
			console.log("onopen...");
			lostConnectionTries = 0;
			// Todo : Add connection status indicator ?
		};

		ws.onclose = function() {
			console.log("onclose...");

			lostConnectionTries++;
			if(lostConnectionTries < maxConnectionTries)
			{
				// Retry...
		        setTimeout(function()
		        {
		        	initConnection(webSocketServer);
		        }, 500);	
			}
			else
			{
				$("#display #main-image").hide('slow');
				$("#display #bot").hide('slow');
				$("#display").text("IRL...");
			}
			
		};

		ws.onmessage = handleMessage;

	}

	var handleMessage = function(event) {
		console.log("onmessage...", event);
		if(debugMode)
		{	addLog(event.data); }
		if(event.data)
		{
			var message = "???";
			var fromHuman = false;
			try
			{
				var parsedMessage = JSON.parse(event.data);
				var status = parsedMessage.status || "";
				var detail = parsedMessage.detail || "";
				switch(status.toLowerCase())
				{
					case "new_order": // Quelle heure ?
						// No "jv_hook new_order" yet
					break;
					case "show_image":
						showImage(detail);
					break;
					case "start_speaking": // Quelle heure ?||il est 18h30
						// Check order presence within speech 
						var separatorIndex = detail.indexOf("||");
						var tempBotSpeech = detail;
						if(separatorIndex > 0)
						{
							var tempOrder = detail.substr(0, detail.indexOf("||"));
							// Write the user order
							addSpeech(true, tempOrder);
							// Write Jarvis speech
							tempBotSpeech = detail.substr(detail.indexOf("||")+2);
							addSpeech(false, tempBotSpeech);
						}
						else
						{
							if(separatorIndex == 0)
							{// Remove order separator
								tempBotSpeech = detail.substr(2);
							}
							addSpeech(false, tempBotSpeech);
						}

						setTimeout(function(){
						updateStatus("speaking");
							var speakDuration = Math.ceil(tempBotSpeech.length/charPerSec)*1000;
							setTimeout(function(){
								updateStatus("neutral");
							}, speakDuration);
						}, speakDelay);

					break;
					case "exiting_cmd" :
						updateStatus("thinking");
					break;
					case "stop_speaking" :
					default:
						updateStatus("neutral");
					break;
				}
				
			}
			catch(ex)
			{
				console.warn("Error parsing message :", ex);
			}
		}	
	};

	var showImage = function(imgUrl)
	{
		console.log("showImage...", imgUrl);	

		$('#image-preview').css('background-image', 'url("'+ imgUrl + '")'); 
		$('#image-modal').modal('show'); 
		setTimeout(function(){ $('#image-modal').modal('hide'); }, 10000);
	};

	var addSpeech = function(fromHuman, message)
	{
		console.log("addSpeech...", fromHuman, message);
		if(message == "" || checkIsRepetition(message))
		{
			return;
		}

		var messageLine = "<li>";
		messageLine += "<span class='who " + (fromHuman?"human":"jarvis") +"'>";
		messageLine += (fromHuman ? userName: botName) + " : </span> ";
		messageLine += message;
		messageLine += "</li>";
		$("#conversation").append(messageLine);
		$("#conversation").animate({
	        scrollTop: $("#conversation")[0].scrollHeight
	    }, 300);
	};

	var checkIsRepetition = function(newMessage)
	{
		var result = false;
		if(newMessage == previousOrder &&
			(Date.now()-previousOrderTime) < repetitionDelay)
		{
			console.log("repetition detected...");
			result = true;
		}

		previousOrder=newMessage;
		previousOrderTime=Date.now();
		
		return result;
	}

	var addLog = function(data)
	{
		console.log("addLog...", data);
		var messageLine = "<li>";
		messageLine += "<span class='who '>";
		messageLine += "Debug" + " : </span> ";
		messageLine += (new Date()).toLocaleTimeString() + " - " + (data || "N/A");
		messageLine += "</li>";
		$("#conversation").append(messageLine);
	};

	var updateStatus = function(newStatus)
	{
		console.log("updateStatus...", newStatus);

		newStatus = validStatus[newStatus] ? newStatus : "neutral";
		if(botFace.length > 0)
		{
			newImage = "img/faces/" + botFace + "/" + newStatus + "/" + newStatus + ".gif";

			$("#display img").attr("src", newImage);
		}
		else
		{
			$("#bot").removeClass("speaking thinking");
			$("#bot").addClass(newStatus);	
		}
	};

	var getUrlParameter = function getUrlParameter(sParam) {
	    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
	        sURLVariables = sPageURL.split('&'),
	        sParameterName,
	        i;

	    for (i = 0; i < sURLVariables.length; i++) {
	        sParameterName = sURLVariables[i].split('=');

	        if (sParameterName[0] === sParam) {
	            return sParameterName[1] === undefined ? true : sParameterName[1];
	        }
	    }
	};

	var userName = getUrlParameter("userName") || "Humain";
	var botName = getUrlParameter("botName") || "Jarvis";
	var botFace = getUrlParameter("botFace") || "";
	var speakDelay = getUrlParameter("speakDelay") || 0;
	var useQwant = getUrlParameter("useQwant")=="true";

	var validStatus = { "speaking" : true, "neutral" : true , "thinking" : true};
	var previousOrder = "";
	var previousOrderTime = 0;
	var repetitionDelay = 3000;
	var charPerSec = 17; // Average speech ratio in characters per second
	var timeToken = Date.now();
	var lostConnectionTries = 0;
	var maxConnectionTries = 5;
	var debugMode = false;

	$(document).ready(function() {
		initScript();
		initConnection('ws://' + location.host + '/');
	});

}(jQuery));