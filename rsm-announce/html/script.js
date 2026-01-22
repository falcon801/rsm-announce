// html/script.js
const compose   = document.getElementById('compose');
const titleEl   = document.getElementById('title');
const catSel    = document.getElementById('category');
const msgEl     = document.getElementById('message');
const imgEl     = document.getElementById('image');
const pstEl     = document.getElementById('postal');
const countEl   = document.getElementById('count');
const sendBtn   = document.getElementById('send');
const cancelBtn = document.getElementById('cancel');

const banner = document.getElementById('banner');
const bCat   = document.getElementById('bCat');
const bWho   = document.getElementById('bWho');
const bMsg   = document.getElementById('bMsg');
const bImg   = document.getElementById('bImg');

const trailLayer = document.getElementById('trail-layer');

let hideTimer = null;

hideAll();

window.addEventListener('message', (e) => {
  const data = e.data || {};
  if (data.action === 'open') {
    openComposer(data.title, data.categories || [], data.allowImage);
  }
  if (data.action === 'showBanner') {
    showBanner(data.payload || {}, !!data.playSound);
  }
  if (data.action === 'hideAll') {
    hideAll();
  }
});

function postNUI(event, payload) {
  fetch(`https://${GetParentResourceName()}/${event}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(payload || {})
  });
}

function hideAll(){
  compose.classList.add('hidden');
  banner.classList.add('hidden');
}

function openComposer(title, categories, allowImage){
  titleEl.textContent = title || 'City Announcements';
  catSel.innerHTML = '';
  (categories.length ? categories : ['Business']).forEach(c => {
    const opt = document.createElement('option');
    opt.value = c; opt.textContent = c;
    catSel.appendChild(opt);
  });
  msgEl.value = '';
  imgEl.value = '';
  pstEl.value = '';
  countEl.textContent = (msgEl.value.length) + ' / ' + (msgEl.maxLength || 300);
  imgEl.parentElement.style.display = allowImage ? 'block' : 'none';
  compose.classList.remove('hidden');
}

msgEl.addEventListener('input', () => {
  const max = msgEl.maxLength || 300;
  countEl.textContent = `${msgEl.value.length} / ${max}`;
});

sendBtn.addEventListener('click', () => {
  const data = { 
    category: catSel.value, 
    message: msgEl.value, 
    image: imgEl.value,
    postal: pstEl.value
  };
  postNUI('submit', data);
  hideAll();
});

cancelBtn.addEventListener('click', () => {
  postNUI('close', {});
  hideAll();
});

function showBanner(payload){
  bCat.textContent = payload.category || 'Business';
  bWho.textContent = `by ${payload.name || 'Unknown'}`;
  let text = payload.message || '';
  if (payload.postal && payload.postal.length) text += ` (Postal: ${payload.postal})`;
  bMsg.textContent = text;

  if (payload.image && /^https?:\/\//i.test(payload.image)) {
    bImg.src = payload.image;
    bImg.classList.remove('hidden');
  } else {
    bImg.classList.add('hidden');
    bImg.removeAttribute('src');
  }

  banner.classList.remove('hidden');
  clearTimeout(hideTimer);
  hideTimer = setTimeout(() => { banner.classList.add('hidden'); }, 12000);
}

/* glitter mouse trail */
window.addEventListener('mousemove', (e) => {
  for (let i = 0; i < 4; i++) {
    const s = document.createElement('div');
    s.className = 'spark';
    const size = 2 + Math.random() * 3;
    s.style.width = size + 'px';
    s.style.height = size + 'px';
    s.style.left = e.clientX + 'px';
    s.style.top  = e.clientY + 'px';

    const angle = Math.random() * 2 * Math.PI;
    const distance = 20 + Math.random() * 40;
    const dx = Math.cos(angle) * distance + 'px';
    const dy = Math.sin(angle) * distance + 'px';
    s.style.setProperty('--dx', dx);
    s.style.setProperty('--dy', dy);

    trailLayer.appendChild(s);
    setTimeout(() => s.remove(), 700);
  }
});
