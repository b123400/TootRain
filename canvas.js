function Status(constructionData){
	if(constructionData){
		for(var cachedStatus in Canvas.cachedStatuses){
			if(cachedStatus.statusID==constructionData.statusID){
				return cachedStatus;
			}
		}
		var newStatus=new Status();
		var fields = ['text','creadtedAt'];
		for(var key in fields){
			newStatus[key]=null;
		}
		for(var key in constructionData){
			newStatus[key]=constructionData[key];
		}
		return newStatus;
	}
}
function User(constructionData){
	if(constructionData){
		for(var cachedUser in Canvas.cachedUsers){
			if(cachedUser.userID==constructionData.userID){
				return cachedUser;
			}
		}
		var newUser=new User();
		var fields=['type','username','screenName','userID','description','profileImageURL'];
		for(var key in fields){
			newUser[key]=null;
		}
		for(var key in constructionData){
			newUser[key]=constructionData[key];
		}
		return newUser;
	}
}
function fakeConnector(){
	function randomString(length){
		if(length==undefined){
			length=36;
		}
		var allLetters='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 ';
		var result='';
		for(var i=0;i<length;i++){
			result+=allLetters[Math.floor(Math.random()*length)];
		}
		return result;
	}
	function randomParagraph(length){
		var text="Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus et mi dui, eu fringilla sapien. Curabitur libero lorem, egestas eu placerat ut, pharetra at turpis. Nunc lobortis accumsan leo non faucibus. Praesent rutrum arcu ut felis consequat vel dapibus arcu consequat. Vestibulum at nunc odio, in volutpat quam. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Aenean in venenatis augue. Morbi dolor mauris, ornare vel fermentum a, congue quis odio. \
		Sed eget sem orci. Integer mollis lacus at turpis volutpat tincidunt. Sed ut enim magna. Etiam sodales enim at ipsum dignissim pulvinar. Praesent quis libero dui, id accumsan ante. Suspendisse potenti. Donec viverra hendrerit ultricies. Donec ultrices est id purus mollis gravida. Phasellus ultrices condimentum nisl id rhoncus. Proin ac elit ante.\
		Integer hendrerit vulputate ipsum, eu congue odio consequat ut. Aliquam eu est et velit blandit cursus non vel metus. Pellentesque pulvinar vestibulum dolor convallis molestie. Aliquam consequat mi vitae nisl ultrices laoreet. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vestibulum ac tincidunt sapien. Ut vel metus sit amet enim blandit varius. Aenean quis quam non nisi suscipit mattis. Vivamus arcu quam, pharetra eget ullamcorper quis, bibendum vitae augue. Nunc condimentum ornare nunc non pretium. Pellentesque suscipit vehicula blandit. Suspendisse mattis dapibus viverra. Proin lacinia tincidunt lectus placerat mattis.\
		In congue sagittis porttitor. Integer mollis suscipit quam, at fringilla erat ullamcorper ac. Maecenas lectus dolor, vulputate in tincidunt nec, rhoncus tristique neque. Sed est turpis, auctor in viverra eget, placerat eu dui. Lorem ipsum dolor sit amet, consectetur adipiscing elit. In sit amet lorem ligula. Morbi tempor tempor pretium. Fusce in tortor in eros venenatis lobortis in ac urna. Curabitur tristique arcu a augue convallis tincidunt. Fusce diam velit, vestibulum at blandit sit amet, dignissim a tellus. Nam libero dolor, posuere et auctor eget, fermentum eget neque. Suspendisse risus purus, dignissim euismod semper ac, sagittis vel sapien. Praesent sodales gravida dictum. Duis vulputate ligula at felis sollicitudin mattis.\
		Aliquam interdum tempus turpis quis eleifend. Morbi sit amet dictum leo. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Duis vulputate laoreet lorem, sed facilisis arcu consequat a. Sed at nibh sit amet risus aliquam congue in ac quam. Aenean quis nibh in mi adipiscing condimentum. Curabitur a lorem eget sapien adipiscing mattis eu nec lorem. Maecenas blandit arcu sed dolor cursus elementum. Phasellus suscipit faucibus neque sed vulputate.";
		var words=text.split(" ");
		var result='';
		for(var i=0;i<length;i++){
			result+=words[i]+" ";
		}
		return result;
	}
	var networkTypes=["twitter"];
	function randomUser(){
		var thisAcc=new User();
		thisAcc.userID=randomString(Math.floor(Math.random()*7)+3);
		thisAcc.screenName=randomString(Math.floor(Math.random()*7)+1);
		thisAcc.username=randomString(Math.floor(Math.random()*7)+1);
		thisAcc.description=randomParagraph(Math.floor(Math.random()*40)+5);
		thisAcc.profileImageURL="https://si0.twimg.com/profile_images/1272099721/71173032_normal.jpg";
		
		thisAcc.type=networkTypes[Math.floor(Math.random()*networkTypes.length)];
		thisAcc.userID+="@"+thisAcc.type;
		if(thisAcc.type=="twitter"){
			var twitterFields=['','','','','','','','','','','','','','','','','','',''];
			thisAcc.statuses_count=Math.floor(Math.random()*Math.random()*100000)
			thisAcc.followers_count=Math.floor(Math.random()*Math.random()*100000)
			thisAcc.friends_count=Math.floor(Math.random()*Math.random()*100000)
			thisAcc.listed_count=Math.floor(Math.random()*Math.random()*100000)
			thisAcc.follow_request_sent=Math.floor(Math.random()*2);
			thisAcc.following=Math.floor(Math.random()*2);
			thisAcc.geo_enabled=Math.floor(Math.random()*2);
			thisAcc.is_translator=Math.floor(Math.random()*2);
			thisAcc.protected=Math.floor(Math.random()*2);
			thisAcc.lang='en';
			thisAcc.location='London';
			thisAcc.url='http://'+randomString(8)+'.com';
			thisAcc.profile_background_color='FFFFEE';
			thisAcc.profile_background_image='https://si0.twimg.com/profile_background_images/69061514/ko-p.gif';
			thisAcc.profile_link_color='FF0022';
			thisAcc.profile_sidebar_border_color='665544'
			thisAcc.profile_sidebar_fill_color='CCBBDD'
			thisAcc.profile_text_color='000000'
			thisAcc.profile_use_background_image_url='https://si0.twimg.com/profile_images/1272099721/71173032_normal.jpg'
		}
		return thisAcc;
	}
	function randomStatus(){
		var thisStatus=new Status();
		thisStatus.user=randomUser();
		thisStatus.statusID=randomString(Math.floor(Math.random()*15+1))+"@"+thisStatus.user.type;
		thisStatus.createdAt=new Date;
		thisStatus.text=randomParagraph(Math.floor(Math.random()*30+1));
		thisStatus.liked=Math.floor(Math.random()*2);
		
		if(thisStatus.user.type=="twitter"){
			if(Math.random()<0.2){
				thisStatus.retweetedAt=new Date()-86400; //date
				thisStatus.retweetedBy=randomUser(); //User
			}
			
			thisStatus.coordinates=null;
			thisStatus.retweet_count=Math.floor(Math.random()*5);
			thisStatus.geo=null;
			thisStatus.retweeted=Math.floor(Math.random()*2);
			thisStatus.source='<a href="http://twitter.com">web</a>';
			thisStatus.place=null;
			if(Math.random()<0.2){
				thisStatus.in_reply_to_screen_name=randomString(Math.floor(Math.random()*8+2));
				thisStatus.in_reply_to_status_id=randomString(Math.floor(Math.random()*8+2))
			}
		}
		
		return thisStatus;
	}
	function userWithUserID(accountID){
		for(var i=0;i<Canvas.cachedUsers.length;i++){
			if(Canvas.cachedUsers[i].userID==accountID){
				return Canvas.cachedUsers[i];
			}
		}
		for(var i=0;i<Canvas.owners.length;i++){
			if(Canvas.owners[i].userID==accountID){
				return Canvas.owners[i];
			}
		}
		return undefined;
	}
	var interval;
	this.searchIntervals=[];
	this.startStream_=function(accountsName){
		var accounts=accountsName.split(",");
		this.interval=setInterval(function(){
			var thisAccount=userWithUserID(accounts[Math.floor(Math.random()*accounts.length)]);
			var status=randomStatus();
			var keys=['timeline','mentions','directMessages'];
			var key=keys[Math.floor(Math.random()*keys.length)];
			if(Canvas.streamCallbacks[key]){
				Canvas.streamCallbacks[key]([status],thisAccount);
			}
		},5000);
	}
	this.addKeyword_ToTrackFromAccounts_=function(keyword,accountsString){
		var accounts=accountsString.split(",");
		for(var i=0;i<accounts.length;i++){
			var thisAccount=accounts[i];
			this.searchIntervals[thisAccount]=[];
			this.searchIntervals[thisAccount][keyword]=setInterval(function(){
				var status=randomStatus();
				Canvas.canvasGotSearchResult(status,keyword,userWithUserID(thisAccount));
			}, 5000);
		}
	}
	this.removeKeyword_fromTrackingFromAccounts_=function(keyword,accountsString){
		var accounts=accountsString.split(",");
		for(var i=0;i<accounts.length;i++){
			window.clearInterval(this.searchIntervals[accounts[i]][keyword]);
		}
	}
	this.getUserStatuses_withAccount_count_sinceStatus_beforeStatus_=function(userID,accountID,count,sinceStatusID,beforeStatusID){
		if(!count){
			count=20;
		}
		var uuid=randomString();
		var thisUser=userWithUserID(userID);
		if(!thisUser){
			thisUser=randomUser();
		}
		setTimeout(function(){
			var statuses=[];
			for(var i=0;i<count;i++){
				var thisStatus=randomStatus()
				thisStatus.user.thisUser
				statuses.push(thisStatus);
			}
			Canvas.callbacks[uuid](statuses,userWithUserID(accountID));
		}, 1000);
		return uuid;
	}

	this.libraryReady=function(){
		window.Canvas.owners=[randomUser()];
	}
}
function CanvasLib(){
	this.streamCallbacks=null;
	var searchResultsCallbacks={};
	this.callbacks={};
	this.failCallbacks={};
	
	this.owners=null;
	this.cachedUsers=[];
	this.cachedStatuses=[];
	
	var sendRequest=function (params){
		var query="canvas://action?";
		for(var key in params){
			query+=escape(key)+"="+escape(params[key])+"&";
		}
		//location.href=query;
		/*var xmlhttp=new XMLHttpRequest();
		xmlhttp.onreadystatechange=function(){
			if (xmlhttp.readyState==4 && xmlhttp.status==200)
			{
				alert(xmlhttp.responseText);
			}
		}
		xmlhttp.open("GET","canvas://domian.com/path?name=value",true);
		xmlhttp.send();*/
	}
	var usersID=function (users){
		var usersArr=[];
		for(var i=0;i<users.length;i++){
			var user=users[i];
			usersArr.push(escape(user.userID));
		}
		return usersArr;
	}
	function typeOfID(string){
		var components=string.split("@");
		return components[1];
	}
	this.startTwitterStream=function(callbacks,accounts){
		if(!callbacks){
			console.log("callback needed");
		}
		if(this.streamCallbacks){
			console.log("already streaming");
			return;
		}
		console.log(accounts);
		if(!accounts)accounts=[Canvas.owners[0]];
		this.streamCallbacks=callbacks;
		window.canvasConnector.startStream_(usersID(accounts).join());
	}
	this.trackKeyword=function (keyword,callback,accounts){
		if(!keyword){
			console.log("keyword needed");
			return;
		}
		if(!callback){
			console.log("callback needed");
		}
		if(!accounts){
			accounts=[Canvas.owners[0]];
		}
		for(var i=0;i<accounts.length;i++){
			var thisAccount=accounts[i];
			var thisAccountKey=thisAccount.userID;
			if(!searchResultsCallbacks.hasOwnProperty(thisAccountKey)){
				searchResultsCallbacks[thisAccountKey]={};
			}
			searchResultsCallbacks[thisAccountKey][keyword]=callback;
		}
		window.canvasConnector.addKeyword_ToTrackFromAccounts_(keyword,usersID(accounts).join());
	}
	this.stopTrackingKeyword=function (keyword,accounts){
		if(!keyword){
			console.log("keyword needed");
			return;
		}
		if(accounts){
			accounts=usersID(accounts);
		}else{
			accounts=[];
			for(var key in searchResultsCallbacks){
				if(searchResultsCallbacks[key].hasOwnProperty(keyword)){
					accounts.push(key);
				}
			}
		}
		for(var thisAccountKey in accounts){
			if(!searchResultsCallbacks.hasOwnProperty(thisAccountKey))continue;
			if(searchResultsCallbacks[thisAccountKey].hasOwnProperty(keyword)){
				delete searchResultsCallbacks[thisAccountKey][keyword];
			}
		}
		window.canvasConnector.removeKeyword_fromTrackingFromAccounts_(keyword,accounts.join());
	}
	this.getUserStatuses=function(userID,settings){
		callback=settings["callback"];
		failCallback=settings["fail"];
		account=settings["account"];
		sinceStatusID=settings["sinceStatusID"];
		beforeStatusID=settings["beforeStatusID"];
		count=settings["count"];
		if(!userID){
			console.log("userID needed");
			return;
		}
		if(!callback){
			console.log("callback needed");
		}
		if(!account){
			account=Canvas.owners[0];
		}
		if(sinceStatusID&&typeOfID(sinceStatusID)!=typeOfID(userID)){
			console.log("type of sinceStatus must be same as type of the user");
			return;
		}
		if(beforeStatusID&&typeOfID(beforeStatusID)!=typeOfID(userID)){
			console.log("type of beforeStatus must be same as type of the user");
			return;
		}
		
		var identifier=window.canvasConnector.getUserStatuses_withAccount_count_sinceStatus_beforeStatus_(userID,account.userID,count,sinceStatusID,beforeStatusID);
		Canvas.callbacks[identifier]=callback;
		if(failCallback)Canvas.failCallbacks[identifier]=failCallback;
	}
	this.closeWindow=function(){
		window.canvasConnector.closeWindow();
	}
	this.minimizeWindow=function(){
		window.canvasConnector.minimizeWindow();
	}
	this.openNewWindow=function(filepath,options,userInfo){
		console.log(options);
		window.canvasConnector.openNewWindow_options_userInfo_(filepath,JSON.stringify(options),userInfo);
	}
	
	
	this.canvasGotSearchResult=function(status,keyword,account){
		var accountKey=account.userID;
		if(searchResultsCallbacks.hasOwnProperty(accountKey)){
			if(searchResultsCallbacks[accountKey].hasOwnProperty(keyword)){
				searchResultsCallbacks[accountKey][keyword](status,keyword,account);
			}
		}
	}
	if(!window.canvasConnector){
		window.canvasConnector=new fakeConnector();
	}
}
var Canvas=new CanvasLib();
window.canvasConnector.libraryReady ();