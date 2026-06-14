<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!doctype html>
<html lang="zh-CN">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>&#26412;&#26426;&#35821;&#38899;&#21161;&#25163;</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .voice-shell{min-height:100vh;padding:28px;background:linear-gradient(180deg,#f7f9fc 0,#eef2f6 100%)}
        .voice-wrap{max-width:980px;margin:0 auto;display:grid;gap:16px}
        .voice-panel{background:#fff;border:1px solid #e2e7ef;border-radius:8px;box-shadow:0 1px 2px rgba(15,23,42,.05);padding:18px}
        .voice-head{display:flex;align-items:center;justify-content:space-between;gap:12px;flex-wrap:wrap;border-bottom:1px solid #e8edf3;padding-bottom:14px;margin-bottom:14px}
        .voice-head h1{font-size:20px;margin:0;color:#162033}
        .voice-status{display:inline-flex;align-items:center;gap:8px;color:#667386;font-size:13px}
        .voice-dot{width:8px;height:8px;border-radius:50%;background:#9aa6b6}
        .voice-dot.active{background:#17834f;box-shadow:0 0 0 4px rgba(23,131,79,.12)}
        .voice-actions{display:flex;gap:10px;flex-wrap:wrap;margin:14px 0}
        .voice-log{height:420px;overflow:auto;border:1px solid #e2e7ef;border-radius:8px;background:#fbfcfe;padding:14px;display:grid;gap:12px;align-content:start}
        .bubble{max-width:82%;padding:11px 13px;border:1px solid #e1e7ef;border-radius:8px;background:#fff;line-height:1.65;white-space:pre-wrap}
        .bubble.user{justify-self:end;background:#eef5ff;border-color:#cbdcf2;color:#173a73}
        .bubble.assistant{justify-self:start;color:#1d293b}
        .voice-input{display:grid;grid-template-columns:1fr auto;gap:10px;margin-top:14px}
        .voice-hint{margin:10px 0 0;color:#667386;font-size:12px;line-height:1.6}
        @media(max-width:720px){.voice-shell{padding:16px}.voice-input{grid-template-columns:1fr}.bubble{max-width:100%}}
    </style>
</head>
<body>
<div class="voice-shell">
    <div class="voice-wrap">
        <div class="voice-panel">
            <div class="voice-head">
                <h1>&#26412;&#26426;&#35821;&#38899;&#21161;&#25163;</h1>
                <span class="voice-status"><i id="dot" class="voice-dot"></i><span id="status">&#23601;&#32490;</span></span>
            </div>
            <div id="log" class="voice-log"></div>
            <div class="voice-actions">
                <button id="listenBtn" class="btn success" type="button">&#25345;&#32493;&#21548;&#20889;</button>
                <button id="autoBtn" class="btn secondary" type="button">&#33258;&#21160;&#38382;&#31572;</button>
                <button id="interruptBtn" class="btn danger" type="button">&#25171;&#26029;&#22238;&#31572;</button>
                <button id="stopBtn" class="btn secondary" type="button">&#20572;&#27490;</button>
                <button id="clearBtn" class="btn secondary" type="button">&#28165;&#31354;</button>
            </div>
            <div class="voice-input">
                <input id="textInput" class="input" placeholder="&#35831;&#35828;&#35805;&#25110;&#36755;&#20837;&#38382;&#39064;">
                <button id="sendBtn" class="btn" type="button">&#21457;&#36865;</button>
            </div>
            <p class="voice-hint">&#25345;&#32493;&#21548;&#20889;&#21482;&#20250;&#25226;&#35821;&#38899;&#36716;&#25104;&#25991;&#23383;&#65292;&#38656;&#35201;&#28857;&#20987;&#21457;&#36865;&#25165;&#20250;&#38382;&#31572;&#12290;&#33258;&#21160;&#38382;&#31572;&#27169;&#24335;&#20250;&#22312;&#21548;&#21040;&#19968;&#21477;&#35805;&#21518;&#33258;&#21160;&#21457;&#36865;&#12290;&#30005;&#33041;&#22238;&#31572;&#26102;&#20250;&#26242;&#20572;&#21548;&#20889;&#65292;&#22238;&#31572;&#23436;&#20877;&#24674;&#22797;&#12290;</p>
        </div>
    </div>
</div>
<script>
(function(){
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
    const log = document.getElementById('log');
    const statusEl = document.getElementById('status');
    const dot = document.getElementById('dot');
    const input = document.getElementById('textInput');
    const listenBtn = document.getElementById('listenBtn');
    const autoBtn = document.getElementById('autoBtn');
    const interruptBtn = document.getElementById('interruptBtn');
    let recognition = null;
    let keepListening = false;
    let autoSend = false;
    let isRecognizing = false;
    let isAsking = false;
    let isSpeaking = false;
    let speechInterrupted = false;
    let currentSpeechResolve = null;
    let committedText = '';

    const text = {
        ready: '\u5c31\u7eea',
        listening: '\u6b63\u5728\u542c\u5199',
        thinking: '\u601d\u8003\u4e2d',
        speaking: '\u6b63\u5728\u56de\u7b54',
        stopped: '\u5df2\u505c\u6b62',
        unsupported: '\u5f53\u524d\u6d4f\u89c8\u5668\u4e0d\u652f\u6301\u8bed\u97f3\u8bc6\u522b',
        error: '\u9519\u8bef',
        start: '\u6301\u7eed\u542c\u5199',
        active: '\u542c\u5199\u4e2d',
        autoStart: '\u81ea\u52a8\u95ee\u7b54',
        autoActive: '\u81ea\u52a8\u95ee\u7b54\u4e2d',
        hello: '\u4f60\u597d\uff0c\u6211\u53ef\u4ee5\u6301\u7eed\u542c\u4f60\u8bf4\u8bdd\uff0c\u4e5f\u53ef\u4ee5\u7528\u6587\u5b57\u56de\u7b54\u3002'
    };

    function setStatus(value, active){
        statusEl.textContent = value;
        dot.classList.toggle('active', !!active);
    }

    function addBubble(role, value){
        const div = document.createElement('div');
        div.className = 'bubble ' + role;
        div.textContent = value;
        log.appendChild(div);
        log.scrollTop = log.scrollHeight;
    }

    function stopRecognitionOnly(){
        if (recognition && isRecognizing) {
            try { recognition.stop(); } catch (err) {}
        }
    }

    function restartListeningSoon(delay){
        if (keepListening && !isSpeaking && !isAsking) setTimeout(safeStart, delay || 350);
    }

    function speak(value){
        return new Promise(function(resolve){
            if (!('speechSynthesis' in window) || !value) {
                resolve();
                return;
            }
            speechInterrupted = false;
            isSpeaking = true;
            currentSpeechResolve = resolve;
            stopRecognitionOnly();
            setStatus(text.speaking, true);
            window.speechSynthesis.cancel();
            const utterance = new SpeechSynthesisUtterance(value);
            utterance.lang = 'zh-CN';
            utterance.rate = 1;
            utterance.onend = function(){
                isSpeaking = false;
                currentSpeechResolve = null;
                resolve();
            };
            utterance.onerror = function(){
                isSpeaking = false;
                currentSpeechResolve = null;
                resolve();
            };
            window.speechSynthesis.speak(utterance);
        });
    }

    function safeStart(){
        if (!recognition || !keepListening || isRecognizing || isAsking || isSpeaking) return;
        try {
            recognition.start();
        } catch (err) {
            setTimeout(safeStart, 500);
        }
    }

    async function ask(value){
        const q = (value || '').trim();
        if (!q) {
            safeStart();
            return;
        }
        isAsking = true;
        addBubble('user', q);
        input.value = '';
        committedText = '';
        setStatus(text.thinking, true);
        try {
            const body = new URLSearchParams();
            body.set('q', q);
            const res = await fetch('http://127.0.0.1:15888/ask', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'},
                body: body.toString()
            });
            const raw = await res.text();
            let data;
            try {
                data = JSON.parse(raw);
            } catch (parseErr) {
                throw new Error('\u540e\u7aef\u8fd4\u56de\u4e0d\u662f\u6709\u6548 JSON: ' + raw.slice(0, 160));
            }
            if (!data.ok) throw new Error(data.error || '\u8bf7\u6c42\u5931\u8d25');
            const answer = (data.answer || '').trim() || '\u6ca1\u6709\u8fd4\u56de\u5185\u5bb9';
            addBubble('assistant', answer);
            await speak(answer);
            setStatus(keepListening ? text.listening : text.ready, keepListening);
        } catch (err) {
            const msg = '\u672c\u5730\u52a9\u624b\u8c03\u7528\u5931\u8d25\uff1a' + err.message;
            addBubble('assistant', msg);
            setStatus(text.error, false);
        } finally {
            isAsking = false;
            restartListeningSoon(700);
        }
    }

    if (SpeechRecognition) {
        recognition = new SpeechRecognition();
        recognition.lang = 'zh-CN';
        recognition.interimResults = true;
        recognition.continuous = true;

        recognition.onstart = function(){
            isRecognizing = true;
            setStatus(text.listening, true);
        };

        recognition.onend = function(){
            isRecognizing = false;
            if (keepListening && !isAsking && !isSpeaking) {
                setTimeout(safeStart, 350);
            } else {
                setStatus(isSpeaking ? text.speaking : text.stopped, isSpeaking);
            }
        };

        recognition.onerror = function(event){
            isRecognizing = false;
            const detail = event.error || text.error;
            setStatus(detail, false);
            addBubble('assistant', '\u8bed\u97f3\u8bc6\u522b\u9519\u8bef\uff1a' + detail);
            if (event.error === 'not-allowed' || event.error === 'service-not-allowed') {
                keepListening = false;
                listenBtn.textContent = text.start;
            }
        };

        recognition.onresult = function(event){
            let finalText = '';
            let interimText = '';
            for (let i = event.resultIndex; i < event.results.length; i++) {
                const transcript = event.results[i][0].transcript;
                if (event.results[i].isFinal) finalText += transcript;
                else interimText += transcript;
            }
            if (finalText.trim()) {
                committedText = (committedText + ' ' + finalText.trim()).trim();
            }
            input.value = (committedText + ' ' + interimText.trim()).trim();
            if (finalText.trim()) {
                recognition.stop();
                if (autoSend) ask(finalText);
                else restartListeningSoon(300);
            }
        };
    } else {
        setStatus(text.unsupported, false);
    }

    listenBtn.onclick = function(){
        keepListening = !keepListening;
        autoSend = false;
        listenBtn.textContent = keepListening ? text.active : text.start;
        autoBtn.textContent = text.autoStart;
        if (keepListening) safeStart();
        else if (recognition) recognition.stop();
    };

    autoBtn.onclick = function(){
        keepListening = !keepListening || !autoSend;
        autoSend = keepListening;
        listenBtn.textContent = keepListening ? text.active : text.start;
        autoBtn.textContent = autoSend ? text.autoActive : text.autoStart;
        if (keepListening) safeStart();
        else if (recognition) recognition.stop();
    };

    interruptBtn.onclick = function(){
        speechInterrupted = true;
        isSpeaking = false;
        if ('speechSynthesis' in window) window.speechSynthesis.cancel();
        if (currentSpeechResolve) {
            const done = currentSpeechResolve;
            currentSpeechResolve = null;
            done();
        }
        setStatus(keepListening ? text.listening : text.ready, keepListening);
        restartListeningSoon(200);
    };

    document.getElementById('stopBtn').onclick = function(){
        keepListening = false;
        autoSend = false;
        listenBtn.textContent = text.start;
        autoBtn.textContent = text.autoStart;
        if (recognition) recognition.stop();
        isSpeaking = false;
        if ('speechSynthesis' in window) window.speechSynthesis.cancel();
        if (currentSpeechResolve) {
            const done = currentSpeechResolve;
            currentSpeechResolve = null;
            done();
        }
        setStatus(text.stopped, false);
    };

    document.getElementById('clearBtn').onclick = function(){
        log.innerHTML = '';
        input.value = '';
        committedText = '';
    };

    document.getElementById('sendBtn').onclick = function(){
        ask(input.value);
    };

    input.addEventListener('keydown', function(event){
        if (event.key === 'Enter') ask(input.value);
    });

    addBubble('assistant', text.hello);
})();
</script>
</body>
</html>
