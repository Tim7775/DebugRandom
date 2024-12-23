"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[395],{9466:(e,n,t)=>{t.r(n),t.d(n,{assets:()=>c,contentTitle:()=>d,default:()=>u,frontMatter:()=>o,metadata:()=>r,toc:()=>i});const r=JSON.parse('{"type":"mdx","permalink":"/DebugRandom/","source":"@site/pages/index.md","title":"DebugRandom","description":"A wrapper around Roblox\'s Random class that enables users to serialize and set the state of the Random object.","frontMatter":{},"unlisted":false}');var a=t(4848),s=t(8453);const o={},d="DebugRandom",c={},i=[{value:"Usage",id:"usage",level:2}];function l(e){const n={a:"a",code:"code",h1:"h1",h2:"h2",header:"header",p:"p",pre:"pre",strong:"strong",...(0,s.R)(),...e.components};return(0,a.jsxs)(a.Fragment,{children:[(0,a.jsx)(n.header,{children:(0,a.jsx)(n.h1,{id:"debugrandom",children:"DebugRandom"})}),"\n",(0,a.jsxs)(n.p,{children:["A wrapper around Roblox's ",(0,a.jsx)(n.a,{href:"https://create.roblox.com/docs/reference/engine/datatypes/Random",children:"Random"})," class that enables users to serialize and set the state of the Random object."]}),"\n",(0,a.jsx)(n.h2,{id:"usage",children:"Usage"}),"\n",(0,a.jsxs)(n.p,{children:[(0,a.jsx)(n.strong,{children:"Example use:"})," Serialize a random number generator's state when an error occurs, so the error can be replicated using DebugRandom",":SetSerializedState"," or DebugRandom.deserialize."]}),"\n",(0,a.jsx)(n.pre,{children:(0,a.jsx)(n.code,{className:"language-lua",children:"local rng = DebugRandom.new()\nprint(rng:NextNumber())\n\nlocal state = rng:Serialize()\nlocal deserializedRng = DebugRandom.deserialize(state)\nassert(rng == deserializedRng)\nassert(rng:NextNumber() == deserializedRng:NextNumber())\n"})})]})}function u(e={}){const{wrapper:n}={...(0,s.R)(),...e.components};return n?(0,a.jsx)(n,{...e,children:(0,a.jsx)(l,{...e})}):l(e)}},8453:(e,n,t)=>{t.d(n,{R:()=>o,x:()=>d});var r=t(6540);const a={},s=r.createContext(a);function o(e){const n=r.useContext(s);return r.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function d(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(a):e.components||a:o(e.components),r.createElement(s.Provider,{value:n},e.children)}}}]);