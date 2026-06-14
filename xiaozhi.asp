<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!doctype html>
<html lang="zh-CN">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>小智同学</title>
    <link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 64 64'%3E%3Ccircle cx='32' cy='32' r='28' fill='%23d94732'/%3E%3Ccircle cx='23' cy='27' r='6' fill='white'/%3E%3Ccircle cx='41' cy='27' r='6' fill='white'/%3E%3Cpath d='M21 42c7 6 15 6 22 0' stroke='%235b1815' stroke-width='4' fill='none' stroke-linecap='round'/%3E%3C/svg%3E">
    <style>
        :root{--bg:#f4f7fb;--surface:#fff;--line:#dfe6ef;--line2:#cbd5e1;--text:#162033;--muted:#607087;--blue:#2563eb;--green:#16805a;--red:#b42318;--pink:#ff4fa3;--violet:#7c3aed;--lobster:#d94732;--lobster2:#a92e24;--lobster3:#ff8f74;--shell:#fff2e8}
        *{box-sizing:border-box}html,body{margin:0;height:100%;font-family:"Microsoft YaHei",Segoe UI,Arial,sans-serif;color:var(--text);background:var(--bg);overflow:hidden}
        .page{height:100vh;display:grid;grid-template-columns:minmax(420px,1fr) 460px;background:linear-gradient(180deg,#f8fafc,#eef3f8);overflow:hidden}
        .stage{position:relative;display:grid;place-items:center;min-height:100vh;padding:28px;border-right:1px solid var(--line);overflow:hidden;background:#fff}
        .stage:before{content:"";position:absolute;left:10%;right:10%;bottom:12%;height:18%;border:1px solid #dbe5f0;border-radius:50%;background:linear-gradient(180deg,#f9fbff,#e9eef7);box-shadow:0 22px 44px rgba(15,23,42,.12),inset 0 1px 0 rgba(255,255,255,.9)}
        .stage:after{content:"";position:absolute;left:16%;right:16%;bottom:20%;height:1px;background:linear-gradient(90deg,transparent,#cbd5e1,transparent)}
        .avatar-card{position:relative;z-index:1;width:min(72vh,610px);max-width:92vw;aspect-ratio:1/1;display:grid;place-items:center;transform-origin:center center}
        .signal-ring{display:none}
        .lobster-svg{position:relative;z-index:1;width:84%;height:84%;object-fit:contain;display:block;filter:drop-shadow(0 18px 18px rgba(151,42,32,.18));user-select:none;pointer-events:none}
        .avatar-card.listening{animation:floatIdle 2.8s ease-in-out infinite}.avatar-card.thinking{animation:floatIdle 1.4s ease-in-out infinite}.avatar-card.speaking{animation:speakBounce .42s ease-in-out infinite}.avatar-card.speaking .lobster-svg{filter:drop-shadow(0 18px 18px rgba(151,42,32,.18)) drop-shadow(0 0 10px rgba(255,180,92,.22))}
        .avatar-eye{position:absolute;z-index:4;width:6.2%;height:6.2%;border-radius:50%;background:#fff;box-shadow:inset 0 0 0 1px rgba(96,32,24,.24),0 2px 6px rgba(92,20,18,.16);pointer-events:none;overflow:hidden}
        .avatar-eye-left{left:39.7%;top:38%}.avatar-eye-right{right:39.7%;top:38%}
        .avatar-pupil{position:absolute;left:50%;top:50%;width:42%;height:42%;border-radius:50%;background:#342020;box-shadow:inset -1px -1px 0 rgba(0,0,0,.18),0 0 0 1px rgba(255,255,255,.12);transform:translate(-50%,-50%);transition:transform .08s linear}
        .avatar-pupil:after{content:"";position:absolute;left:20%;top:18%;width:28%;height:28%;border-radius:50%;background:rgba(255,255,255,.86)}
        .avatar-mouth{position:absolute;z-index:3;left:50%;top:49.5%;width:4.8%;height:1.5%;border-radius:999px;background:#6f1d1b;transform:translate(-50%,-50%) scaleY(.28);transform-origin:center;pointer-events:none;opacity:0}
        .antenna-glow{position:absolute;z-index:2;width:8.5%;height:8.5%;border-radius:50%;background:radial-gradient(circle,rgba(255,255,255,.92) 0 12%,rgba(255,205,116,.62) 20%,rgba(255,143,84,.24) 48%,rgba(255,143,84,0) 72%);filter:blur(1.4px);opacity:.16;mix-blend-mode:screen;pointer-events:none}
        .antenna-glow-left{left:30.2%;top:13.1%}.antenna-glow-right{right:30.2%;top:13.1%}
        .body-glow,.eye-spark{display:none}
        .avatar-card.speaking .avatar-mouth{opacity:.72;animation:mouthTalk .18s ease-in-out infinite}.avatar-card.speaking .antenna-glow{animation:antennaPulse .74s ease-in-out infinite}.avatar-card.thinking .antenna-glow{opacity:.42;animation:antennaThink 1.2s ease-in-out infinite}
        .escape-tip{display:none}
        .side{height:100vh;min-height:0;background:rgba(255,255,255,.9);backdrop-filter:blur(16px);padding:26px;display:flex;flex-direction:column;overflow:hidden}
        .head{display:flex;align-items:flex-start;justify-content:space-between;gap:14px;padding-bottom:16px;border-bottom:1px solid var(--line)}h1{font-size:24px;line-height:1.25;margin:0}.desc{margin:8px 0 0;color:var(--muted);font-size:13px;line-height:1.7}.pill{display:inline-flex;align-items:center;gap:8px;border:1px solid var(--line);background:#fff;border-radius:999px;padding:7px 10px;color:var(--muted);font-size:12px;white-space:nowrap}.dot{width:8px;height:8px;border-radius:50%;background:#94a3b8}.dot.on{background:var(--green);box-shadow:0 0 0 4px rgba(22,128,90,.12)}
        .status{margin:16px 0;border:1px solid var(--line);border-radius:8px;background:#fff;padding:14px;box-shadow:0 1px 2px rgba(15,23,42,.04)}.label{font-size:12px;color:var(--muted);margin-bottom:6px}.value{font-size:18px;font-weight:700}.meta{display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-top:12px}.meta div{border:1px solid var(--line);border-radius:8px;background:#fbfcfe;padding:9px}.meta span{display:block;color:var(--muted);font-size:12px;margin-bottom:4px}.meta strong{font-size:13px}
        .actions{display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:16px}button{height:40px;border:1px solid var(--line2);border-radius:8px;background:#fff;color:var(--text);font-size:14px;cursor:pointer;transition:.15s ease}button:hover{border-color:#9fb0c5;box-shadow:0 6px 14px rgba(15,23,42,.07)}.primary{background:#1f5edc;border-color:#1f5edc;color:#fff}.danger{color:var(--red);background:#fff8f7;border-color:#efc2bc}.test{color:#1e3a8a;background:#f4f7ff;border-color:#c8d8f6}
        .log{height:clamp(250px,38vh,430px);min-height:0;max-height:430px;overflow-y:auto;overflow-x:hidden;border:1px solid var(--line);border-radius:8px;background:#fbfcfe;padding:12px;display:grid;gap:10px;align-content:start;scrollbar-gutter:stable}.bubble{max-width:95%;border:1px solid var(--line);border-radius:8px;background:#fff;padding:9px 11px;font-size:14px;line-height:1.65;white-space:pre-wrap;overflow-wrap:anywhere}.bubble.user{justify-self:end;background:#eaf1ff;border-color:#c8d8f6;color:#173a73}.bubble.assistant{justify-self:start}.bubble.system{justify-self:center;background:transparent;border-style:dashed;color:var(--muted);font-size:12px}.hint{flex:0 0 auto;margin:12px 0 0;color:var(--muted);font-size:12px;line-height:1.7}
        body.focus-mode .page{grid-template-columns:1fr}body.focus-mode .side{display:none}body.focus-mode .stage{position:fixed;inset:0;z-index:50;border:0;min-height:100vh}body.focus-mode .stage:before{inset:18px;border-radius:18px}body.focus-mode .avatar-card{width:min(88vmin,820px)}body.focus-mode .lobster-svg{width:88%;height:88%}body.focus-mode .escape-tip{display:none}
        @keyframes ring{0%,100%{transform:scale(.98);opacity:.75}50%{transform:scale(1.04);opacity:1}}@keyframes spin{to{transform:rotate(360deg)}}@keyframes floatIdle{0%,100%{transform:translateY(0) scale(1)}50%{transform:translateY(-3px) scale(1.006)}}@keyframes speakBounce{0%,100%{transform:translateY(0) scale(1)}50%{transform:translateY(-4px) scale(1.015)}}@keyframes mouthTalk{0%,100%{transform:translate(-50%,-50%) scaleY(.35) scaleX(1.06)}50%{transform:translate(-50%,-50%) scaleY(1.28) scaleX(.82)}}@keyframes antennaPulse{0%,100%{opacity:.18;filter:blur(1.4px);transform:scale(.94)}50%{opacity:.72;filter:blur(3.2px);transform:scale(1.18)}}@keyframes antennaThink{0%,100%{opacity:.12;transform:scale(.96)}50%{opacity:.24;transform:scale(1.06)}}@keyframes bodyPulse{0%,100%{opacity:.52;transform:translate(-50%,-50%) scale(.92)}50%{opacity:.86;transform:translate(-50%,-50%) scale(1.1)}}@keyframes look{0%,100%{transform:translateX(0)}50%{transform:translateX(-5px)}}@keyframes blink{0%,100%{opacity:.25;transform:scale(.8)}50%{opacity:1;transform:scale(1.25)}}
        @media(max-width:900px){.page{grid-template-columns:1fr}.stage{min-height:48vh;border-right:0;border-bottom:1px solid var(--line)}.side{min-height:52vh;padding:18px}.avatar-card{width:min(48vh,520px)}.actions{grid-template-columns:1fr}.head{flex-direction:column}.pill{white-space:normal}}
    </style>
</head>
<body>
<main class="page">
    <section class="stage">
        <div id="avatarCard" class="avatar-card listening">
            <div class="signal-ring"></div>
            <img id="avatar" class="lobster-svg listening" src="assets/xiaozhi-lobster-robot.png" alt="小智同学龙虾机器人助手">
            <span class="avatar-eye avatar-eye-left" aria-hidden="true"><span class="avatar-pupil"></span></span>
            <span class="avatar-eye avatar-eye-right" aria-hidden="true"><span class="avatar-pupil"></span></span>
            <span class="antenna-glow antenna-glow-left" aria-hidden="true"></span>
            <span class="antenna-glow antenna-glow-right" aria-hidden="true"></span>
            <span class="body-glow" aria-hidden="true"></span>
            <span class="eye-spark eye-spark-left" aria-hidden="true"></span>
            <span class="eye-spark eye-spark-right" aria-hidden="true"></span>
            <span class="avatar-mouth" aria-hidden="true"></span>
            <div class="escape-tip">已进入小智全屏模式，按 ESC 返回控制页面</div>
        </div>
    </section>
    <section class="side">
        <div class="head"><div><h1>小智同学</h1><p class="desc">启动后进入连续语音对话。你说一句，小龙虾回答一句；回答时自动暂停监听，回答结束后继续听你说话。</p></div><div class="pill"><i id="dot" class="dot"></i><span id="badgeText">待机</span></div></div>
        <div class="status"><div class="label">当前状态</div><div id="statusText" class="value">点击启动开始连续语音对话</div><div class="meta"><div><span>对话模式</span><strong>连续语音</strong></div><div><span>后端</span><strong id="backendText">检测中</strong></div></div></div>
        <div class="actions"><button id="startBtn" class="primary" type="button">启动小智</button><button id="interruptBtn" class="danger" type="button">打断回答</button><button id="sleepBtn" type="button">暂停对话</button><button id="stopBtn" type="button">停止监听</button><button id="testBtn" class="test" type="button">功能自检</button><button id="clearBtn" type="button">清空记录</button></div>
        <div id="log" class="log" aria-live="polite"></div>
        <p class="hint">第一次使用需要允许浏览器麦克风权限。点击“启动小智”后直接说话即可；说“休息”或点击“暂停对话”会停止连续对话。“功能自检”用于验证问答和朗读链路。</p>
    </section>
</main>
<script>
(function(){
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
    const API = 'http://127.0.0.1:15888/ask';
    const avatar = document.getElementById('avatar');
    const avatarCard = document.getElementById('avatarCard');
    const dot = document.getElementById('dot');
    const badgeText = document.getElementById('badgeText');
    const statusText = document.getElementById('statusText');
    const backendText = document.getElementById('backendText');
    const log = document.getElementById('log');
    const eyeNodes = Array.from(document.querySelectorAll('.avatar-eye'));
    let recognition, keepListening = false, isRecognizing = false, isSpeaking = false, isAsking = false;
    let pendingSpeechText = '', speechSubmitTimer = null;
    const SPEECH_SILENCE_MS = 850;
    const copy = {standby:'点击启动开始连续语音对话',listening:'正在听你说话',awake:'我在，请说',thinking:'思考中',speaking:'正在回答',stopped:'已停止监听',micDenied:'麦克风权限未开启',unsupported:'当前浏览器不支持语音识别'};

    function normalize(v){return (v || '').toLowerCase().replace(/[\s，。！？、,.!?;；:：\-_'"“”‘’（）()\[\]{}]/g,'');}
    function updateEyes(clientX,clientY){
        eyeNodes.forEach(eye=>{
            const pupil = eye.querySelector('.avatar-pupil');
            if(!pupil) return;
            const r = eye.getBoundingClientRect();
            const cx = r.left + r.width / 2;
            const cy = r.top + r.height / 2;
            const dx = clientX - cx;
            const dy = clientY - cy;
            const len = Math.hypot(dx,dy) || 1;
            const max = r.width * 0.13;
            const x = Math.max(-max,Math.min(max,dx / len * max));
            const y = Math.max(-max,Math.min(max,dy / len * max));
            pupil.style.transform = 'translate(calc(-50% + ' + x.toFixed(2) + 'px), calc(-50% + ' + y.toFixed(2) + 'px))';
        });
    }
    function resetEyes(){eyeNodes.forEach(eye=>{const pupil=eye.querySelector('.avatar-pupil');if(pupil)pupil.style.transform='translate(-50%,-50%)';});}
    window.addEventListener('pointermove',e=>updateEyes(e.clientX,e.clientY),{passive:true});
    window.addEventListener('pointerleave',resetEyes);
    window.addEventListener('blur',resetEyes);
    function enterFocus(){document.body.classList.add('focus-mode');}
    function exitFocus(){document.body.classList.remove('focus-mode');}
    function setMode(mode,status,badge,on){avatar.setAttribute('class','lobster-svg ' + mode);avatarCard.setAttribute('class','avatar-card ' + mode);statusText.textContent=status;badgeText.textContent=badge;dot.classList.toggle('on',!!on);}
    function add(role,text){const d=document.createElement('div');d.className='bubble '+role;d.textContent=text;log.appendChild(d);log.scrollTop=log.scrollHeight;}
    function noteRecognitionIssue(detail){
        const quietErrors = ['no-speech','network','aborted','audio-capture'];
        if(quietErrors.indexOf(detail) >= 0){
            setMode('listening', keepListening ? copy.listening : copy.standby, keepListening ? '监听中' : '待机', keepListening);
            return;
        }
        add('system','语音识别错误：'+detail);
    }
    function stopRec(){if(recognition && isRecognizing){try{recognition.stop();}catch(e){}}}
    function startRec(delay){if(!recognition || !keepListening || isRecognizing || isSpeaking || isAsking) return; setTimeout(()=>{if(!recognition || !keepListening || isRecognizing || isSpeaking || isAsking) return; try{recognition.start();}catch(e){setTimeout(()=>startRec(0),700);}},delay||0);}
    function clearSpeechTimer(){if(speechSubmitTimer) clearTimeout(speechSubmitTimer); speechSubmitTimer=null;}
    function submitRecognizedSpeech(text){clearSpeechTimer();pendingSpeechText='';if(!text || isSpeaking || isAsking || !keepListening)return;stopRec();handleSpeech(text);}
    function scheduleSpeechSubmit(text){pendingSpeechText=(text||'').trim();clearSpeechTimer();if(!pendingSpeechText)return;speechSubmitTimer=setTimeout(()=>submitRecognizedSpeech(pendingSpeechText),SPEECH_SILENCE_MS);}
    let voiceList=[], preferredVoice=null, speechUnlocked=false, currentUtterance=null;
    function refreshVoices(){if(!('speechSynthesis' in window)) return []; voiceList=window.speechSynthesis.getVoices() || []; preferredVoice=voiceList.find(v=>/^zh/i.test(v.lang||'')) || voiceList.find(v=>/Chinese|中文|普通话|Mandarin/i.test(v.name||'')) || voiceList[0] || null; return voiceList;}
    function primeSpeech(){if(!('speechSynthesis' in window)) {add('system','当前浏览器不支持语音播报。');return;} refreshVoices(); if(speechUnlocked) return; try{const u=new SpeechSynthesisUtterance(' '); u.lang='zh-CN'; u.volume=0.01; if(preferredVoice) u.voice=preferredVoice; currentUtterance=u; u.onstart=()=>{speechUnlocked=true;}; u.onend=()=>{currentUtterance=null;}; window.speechSynthesis.cancel(); window.speechSynthesis.resume(); window.speechSynthesis.speak(u);}catch(e){add('system','语音播报初始化失败：'+(e.message||e));}}
    if('speechSynthesis' in window){refreshVoices(); window.speechSynthesis.onvoiceschanged=refreshVoices;}
    function speak(text){return new Promise(resolve=>{if(!('speechSynthesis' in window) || !text){if(!('speechSynthesis' in window)) add('system','当前浏览器不支持语音播报，只能显示文字。');resolve();return;} refreshVoices(); isSpeaking=true; stopRec(); setMode('speaking',copy.speaking,'回答中',true); let done=false; const finish=(reason)=>{if(done)return;done=true;clearTimeout(fallback);isSpeaking=false;currentUtterance=null;if(reason)add('system',reason);resolve();}; const u=new SpeechSynthesisUtterance(text); currentUtterance=u; u.lang=(preferredVoice&&preferredVoice.lang)||'zh-CN'; u.rate=1; u.pitch=1.05; if(preferredVoice) u.voice=preferredVoice; u.onstart=()=>{speechUnlocked=true;}; u.onend=()=>finish(); u.onerror=e=>finish('语音播报失败：'+(e.error||'unknown')+'。请确认浏览器没有静音，并点击“启动小智”后再试。'); const fallback=setTimeout(()=>finish('语音播报超时，已恢复监听。'),Math.min(20000,Math.max(4500,text.length*220))); try{window.speechSynthesis.cancel(); window.speechSynthesis.resume(); setTimeout(()=>{try{window.speechSynthesis.resume(); window.speechSynthesis.speak(u);}catch(e){finish('语音播报启动失败：'+(e.message||e));}},80);}catch(e){finish('语音播报启动失败：'+(e.message||e));}});}
    async function ask(q){q=(q||'').trim(); if(!q){startRec(250);return;} if(['休息','退下','暂停','不用了','停止'].includes(normalize(q))){keepListening=false;add('user',q);await speak('好的，我先暂停。');setMode('listening',copy.stopped,'已停止',false);return;} isAsking=true;add('user',q);setMode('thinking',copy.thinking,'思考中',true);try{const body=new URLSearchParams();body.set('q',q);const res=await fetch(API,{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded;charset=UTF-8'},body:body.toString()});const raw=await res.text();let data;try{data=JSON.parse(raw)}catch(e){throw new Error('后端返回不是有效 JSON：'+raw.slice(0,80));}if(!data.ok)throw new Error(data.error||'请求失败');const answer=(data.answer||'').trim()||'我没有获取到回答。';add('assistant',answer);await speak(answer);setMode('listening',copy.listening,'监听中',keepListening);}catch(e){add('system','本地助手调用失败：'+e.message);setMode('listening',keepListening?'请再说一遍':copy.standby,keepListening?'监听中':'待机',keepListening);}finally{isAsking=false;startRec(600);}}
    async function handleSpeech(raw){const text=(raw||'').trim(); if(!text || isSpeaking || isAsking || !keepListening) return; await ask(text);}
    function initRecognition(){if(recognition) return; if(!SpeechRecognition){setMode('listening',copy.unsupported,'不可用',false);add('system',copy.unsupported);return;} recognition=new SpeechRecognition();recognition.lang='zh-CN';recognition.interimResults=true;recognition.continuous=true;recognition.onstart=()=>{isRecognizing=true;setMode('listening',copy.listening,'监听中',true);};recognition.onend=()=>{isRecognizing=false;if(keepListening&&!isSpeaking&&!isAsking)startRec(250);};recognition.onerror=e=>{isRecognizing=false;const detail=e.error||'unknown';if(detail==='not-allowed'||detail==='service-not-allowed'){keepListening=false;clearSpeechTimer();setMode('listening',copy.micDenied,'错误',false);add('system','麦克风权限未开启，请允许浏览器使用麦克风后再启动。');return;}noteRecognitionIssue(detail);startRec(650);};recognition.onresult=e=>{let finalText='',interimText='';for(let i=e.resultIndex;i<e.results.length;i++){const transcript=e.results[i][0].transcript;if(e.results[i].isFinal)finalText+=transcript;else interimText+=transcript;}if(finalText.trim()){submitRecognizedSpeech(finalText);}else if(interimText.trim()){scheduleSpeechSubmit(interimText);}};}
    function start(focus){primeSpeech();if(focus) enterFocus(); keepListening=true;initRecognition();add('system','连续语音对话已启动，请直接说话。');setMode('listening',copy.listening,'监听中',true);startRec(0);}
    async function health(){try{const r=await fetch('http://127.0.0.1:15888/health');const j=await r.json();backendText.textContent=j.ok?j.model:'异常';}catch(e){backendText.textContent='未连接';add('system','语音后端未连接：'+e.message);}}
    document.getElementById('startBtn').onclick=()=>start(true);document.getElementById('interruptBtn').onclick=()=>{clearSpeechTimer();window.speechSynthesis&&window.speechSynthesis.cancel();isSpeaking=false;isAsking=false;setMode('listening',keepListening?copy.listening:copy.standby,keepListening?'监听中':'待机',keepListening);startRec(250);};document.getElementById('sleepBtn').onclick=()=>{keepListening=false;clearSpeechTimer();stopRec();setMode('listening',copy.stopped,'已停止',false);};document.getElementById('stopBtn').onclick=()=>{keepListening=false;clearSpeechTimer();stopRec();window.speechSynthesis&&window.speechSynthesis.cancel();isSpeaking=false;exitFocus();setMode('listening',copy.stopped,'已停止',false);};document.getElementById('clearBtn').onclick=()=>{log.innerHTML='';};document.getElementById('testBtn').onclick=()=>{primeSpeech();if(!keepListening) keepListening=true;handleSpeech('你是谁');};
    function handleEscape(e){if(e.key==='Escape'||e.key==='Esc'){exitFocus();}}
    window.addEventListener('keydown',handleEscape,true);
    window.addEventListener('keyup',handleEscape,true);
    window.__xiaozhiTest = handleSpeech;
    setMode('listening',copy.standby,'待机',false);add('system','页面已就绪。点击“启动小智”开始连续语音对话。');health();
})();
</script>
</body>
</html>
