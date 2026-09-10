const nav=document.querySelector('.topnav');
const toggle=document.querySelector('.nav-toggle');
const navlinks=document.querySelector('.navlinks');
toggle?.addEventListener('click',()=>navlinks.classList.toggle('open'));
window.addEventListener('scroll',()=>nav?.classList.toggle('scrolled',scrollY>40));

const observer=new IntersectionObserver(entries=>{
  entries.forEach(e=>{if(e.isIntersecting)e.target.classList.add('visible')})
},{threshold:.12});
document.querySelectorAll('.reveal').forEach(el=>observer.observe(el));

const places={
  upperhall:{k:'A seat of power',t:'Upperhall',c:'One of Roo’s established places, reached by roads that cross a kingdom beginning to fracture.'},
  dales:{k:'Rebellion',t:'The Dales',c:'Jarl Resgar Vasa’s rebellion has destabilized royal authority and forced questions of freedom, slavery and loyalty into the open.',l:'/lore/the-dales.html'},
  hammerhill:{k:'Old stone, new danger',t:'Hammerhill',c:'A place where human settlement and the remains of the ancient world stand uncomfortably close together.'},
  husby:{k:'On the road south',t:'Husby',c:'An established settlement in Roo, linked to the roads and conflicts moving through the kingdom.'},
  blueridge:{k:'The mountains remember',t:'Blue Ridge Mountain',c:'A mountain region associated with hidden paths, dangerous encounters and things ordinary people dismiss as superstition.'},
  devil:{k:'The northern heights',t:"Devil's Mountain",c:'A mountain landmark in Roo, part of a colder and more difficult landscape where knowledge thins with every mile north.'},
  triport:{k:'The sea opens again',t:'Triport',c:'A coastal city where Varren’s enormous ships arrive after centuries in which Roo had almost no meaningful contact with the wider world.',l:'/lore/triport.html'},
  goths:{k:'Off the coast',t:'Goths Island',c:'An established island in the waters around Roo, part of a coastline shaped by fjords, dangerous seas and long isolation.'},
  tidal:{k:'Ancient technology',t:'The Tidal Gate',c:'A colossal sea gate built into a wall-like structure between two seas. Humanity can still see what it does. Nobody understands how it was made.',l:'/lore/tidal-gate.html'}
};
const panel=document.querySelector('#place-panel');
document.querySelectorAll('.place').forEach(el=>{
  const open=()=>{
    const p=places[el.dataset.place]; if(!p)return;
    document.querySelector('#place-kicker').textContent=p.k;
    document.querySelector('#place-title').textContent=p.t;
    document.querySelector('#place-copy').textContent=p.c;
    const a=document.querySelector('#place-link');
    if(p.l){a.href=p.l;a.classList.remove('hidden')}else a.classList.add('hidden');
    panel?.classList.add('open');
  };
  el.addEventListener('click',open);el.addEventListener('keydown',e=>{if(e.key==='Enter'||e.key===' ')open()});
});
document.querySelector('.panel-close')?.addEventListener('click',()=>panel?.classList.remove('open'));

const people={
 fander:{role:'The curious one',name:'Fander',copy:'He notices what other people walk past. He talks to strangers. He asks the question everyone else decided not to ask.',link:'/characters/fander.html'},
 morango:{role:'The principled one',name:'Morango',copy:'He hates racism, slavery and captivity. When the world makes cruelty normal, Morango is the brother most likely to say that normal is not good enough.',link:'/characters/morango.html'},
 karden:{role:'The dangerous opportunist',name:'Karden',copy:'Cunning, selfish and manipulative. Around him, objects break, structures fail and accidents happen. Whether Karden causes the misfortune is still unknown.',link:'/characters/karden.html'}
};
document.querySelectorAll('.person-tab').forEach(btn=>btn.addEventListener('click',()=>{
 document.querySelectorAll('.person-tab').forEach(b=>b.classList.remove('active'));btn.classList.add('active');
 const p=people[btn.dataset.person];document.querySelector('#person-role').textContent=p.role;document.querySelector('#person-name').textContent=p.name;document.querySelector('#person-copy').textContent=p.copy;document.querySelector('#person-link').href=p.link;
}));

const discoveries=[
 {type:'The old world',title:'The stairs are too large for humans.',copy:'Across Roo, ancient structures were built on a scale that does not fit the people who live among them now. A single step can rise almost to a human waist.',link:'/lore/vanir-ruins.html'},
 {type:'The Moonless Sky',title:'The moon did not fall. It vanished.',copy:'Around two thousand years ago the moon disappeared, the seas rose and maritime routes collapsed. Roo remembers the disaster. Its cause remains unknown.',link:'/lore/moonless-sky.html'},
 {type:'Highward',title:'A human capital built on something inhuman.',copy:'The capital of Varren sits directly atop an enormous Vanir ruin. Deep beneath it is a machine Varren has never fully activated.',link:'/lore/varren-highward.html'},
 {type:'Magic',title:'A lie can become reality.',copy:'Lie magic allows something untrue or normally impossible to function as reality — but powerful lies are unstable, difficult to sustain and corrupting.',link:'/lore/magic.html'},
 {type:'Drianor',title:'Some machines answer to blood.',copy:'Drianor could activate and control Vanir machines. Fander carries his bloodline without knowing what that means.',link:'/lore/drianor.html'},
 {type:'The hidden world',title:'Most people are wrong about monsters.',copy:'Trolls, woodlings, rå and other hidden beings exist, yet encounters are so rare that ordinary people often dismiss them as superstition.',link:'/lore/hidden-beings.html'}
];
document.querySelector('#random-discovery')?.addEventListener('click',()=>{
 const d=discoveries[Math.floor(Math.random()*discoveries.length)];
 document.querySelector('#discovery-type').textContent=d.type;document.querySelector('#discovery-title').textContent=d.title;document.querySelector('#discovery-copy').textContent=d.copy;
 const a=document.querySelector('#discovery-link');a.href=d.link;a.classList.remove('hidden');
});

const scores={curious:0,guard:0,clever:0};let step=0;
document.querySelectorAll('.quiz-step button').forEach(btn=>btn.addEventListener('click',()=>{
 scores[btn.dataset.value]++;document.querySelector(`.quiz-step[data-step="${step}"]`)?.classList.remove('active');step++;
 if(step<3){document.querySelector(`.quiz-step[data-step="${step}"]`)?.classList.add('active');return}
 const winner=Object.entries(scores).sort((a,b)=>b[1]-a[1])[0][0];
 const result={
  curious:['The Question-Seeker','You would follow the strange road because not knowing would bother you more than the danger. Fander would probably start talking to you.'],
  guard:['The Watcher','You would enter Roo looking first at who is being hurt, who is in danger and who is pretending not to notice. Morango would understand you.'],
  clever:['The Survivor','You read the room before you choose a side. In Roo, that can keep you alive — although Karden might still try to use you.']
 }[winner];
 const r=document.querySelector('#quiz-result');r.innerHTML=`<p class="eyebrow">Your traveller profile</p><h3>${result[0]}</h3><p>${result[1]}</p><button onclick="location.reload()">Walk the road again</button>`;r.classList.remove('hidden');
}));

document.querySelectorAll('a[href^="#"]').forEach(a=>a.addEventListener('click',()=>navlinks?.classList.remove('open')));

// Asset reliability + performance: only preload above-the-fold art; lazy-load the rest.
['/assets/hero-roo.svg','/assets/arwen-brothers.svg'].forEach(href=>{
  if(!document.querySelector(`link[rel="preload"][href="${href}"]`)){
    const l=document.createElement('link');l.rel='preload';l.as='image';l.href=href;document.head.appendChild(l);
  }
});
document.querySelectorAll('img').forEach(img=>{
  img.decoding='async';
  if(!img.closest('.portal')) img.loading='lazy';
  img.addEventListener('error',()=>{
    if(!img.dataset.fallbackApplied){img.dataset.fallbackApplied='true';img.src='/assets/hero-roo.svg';}
  });
});

// Keep content visible even if IntersectionObserver or animation support is limited.
document.querySelectorAll('.reveal').forEach(el=>el.classList.add('visible'));
const perfStyle=document.createElement('style');
perfStyle.textContent='.reveal{opacity:1!important;transform:none!important}.portal,.book-section{background-attachment:scroll!important}.portrait-stage{background-image:linear-gradient(90deg,rgba(3,8,9,.76),rgba(3,8,9,.08) 65%),linear-gradient(0deg,rgba(3,8,9,.72),transparent 60%),url("/assets/arwen-brothers.svg")!important;background-size:cover!important;background-position:center!important}';
document.head.appendChild(perfStyle);
