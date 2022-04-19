(self.webpackChunk_N_E=self.webpackChunk_N_E||[]).push([[96033],{74833:function(n,e,o){var a=o(256127),t=/^\s+/;n.exports=function(n){return n?n.slice(0,a(n)+1).replace(t,""):n}},256127:function(n){var e=/\s/;n.exports=function(n){for(var o=n.length;o--&&e.test(n.charAt(o)););return o}},266726:function(n,e,o){var a=o(911611),t=o(882846),r=o(491936),i=Math.max,s=Math.min;n.exports=function(n,e,o){var c,l,p,d,u,h,f=0,m=!1,k=!1,g=!0;if("function"!=typeof n)throw new TypeError("Expected a function");function y(e){var o=c,a=l;return c=l=void 0,f=e,d=n.apply(a,o)}function v(n){return f=n,u=setTimeout(x,e),m?y(n):d}function b(n){var o=n-h;return void 0===h||o>=e||o<0||k&&n-f>=p}function x(){var n=t();if(b(n))return B(n);u=setTimeout(x,function(n){var o=e-(n-h);return k?s(o,p-(n-f)):o}(n))}function B(n){return u=void 0,g&&c?y(n):(c=l=void 0,d)}function w(){var n=t(),o=b(n);if(c=arguments,l=this,h=n,o){if(void 0===u)return v(h);if(k)return clearTimeout(u),u=setTimeout(x,e),y(h)}return void 0===u&&(u=setTimeout(x,e)),d}return e=r(e)||0,a(o)&&(m=!!o.leading,p=(k="maxWait"in o)?i(r(o.maxWait)||0,e):p,g="trailing"in o?!!o.trailing:g),w.cancel=function(){void 0!==u&&clearTimeout(u),f=0,c=h=l=u=void 0},w.flush=function(){return void 0===u?d:B(t())},w}},911611:function(n){n.exports=function(n){var e=typeof n;return null!=n&&("object"==e||"function"==e)}},882846:function(n,e,o){var a=o(377400);n.exports=function(){return a.Date.now()}},819783:function(n,e,o){var a=o(266726),t=o(911611);n.exports=function(n,e,o){var r=!0,i=!0;if("function"!=typeof n)throw new TypeError("Expected a function");return t(o)&&(r="leading"in o?!!o.leading:r,i="trailing"in o?!!o.trailing:i),a(n,e,{leading:r,maxWait:e,trailing:i})}},491936:function(n,e,o){var a=o(74833),t=o(911611),r=o(455193),i=/^[-+]0x[0-9a-f]+$/i,s=/^0b[01]+$/i,c=/^0o[0-7]+$/i,l=parseInt;n.exports=function(n){if("number"==typeof n)return n;if(r(n))return NaN;if(t(n)){var e="function"==typeof n.valueOf?n.valueOf():n;n=t(e)?e+"":e}if("string"!=typeof n)return 0===n?n:+n;n=a(n);var o=s.test(n);return o||c.test(n)?l(n.slice(2),o?2:8):i.test(n)?NaN:+n}},678105:function(n,e,o){"use strict";o.r(e),o.d(e,{default:function(){return m}});var a,t=o(827378),r=o(494616),i=o(25778),s=o(707765),c=o(412088),l=o(871649),p=o(824246);var d,u={en:{description:"The backdrop component is used to provide emphasis on a particular element or parts of it.",location:"/docs/src/pages/components/backdrop/backdrop.md",rendered:['<svg style="display: none;" xmlns="http://www.w3.org/2000/svg">\n  <symbol id="anchor-link-icon" viewBox="0 0 16 16">\n    <path d="M4 9h1v1H4c-1.5 0-3-1.69-3-3.5S2.55 3 4 3h4c1.45 0 3 1.69 3 3.5 0 1.41-.91 2.72-2 3.25V8.59c.58-.45 1-1.27 1-2.09C10 5.22 8.98 4 8 4H4c-.98 0-2 1.22-2 2.5S3 9 4 9zm9-3h-1v1h1c1 0 2 1.22 2 2.5S13.98 12 13 12H9c-.98 0-2-1.22-2-2.5 0-.83.42-1.64 1-2.09V6.25c-1.09.53-2 1.84-2 3.25C6 11.31 7.55 13 9 13h4c1.45 0 3-1.69 3-3.5S14.5 6 13 6z" />\n  </symbol>\n</svg>','<h1>Backdrop</h1><p class="description">The backdrop component is used to provide emphasis on a particular element or parts of it.</p>\n\n<p>The backdrop signals to the user of a state change within the application and can be used for creating loaders, dialogs, and more.\nIn its simplest form, the backdrop component will add a dimmed layer over your application.</p>\n',{component:"modules/components/ComponentLinkHeader.js"},'<h2 id="heading-example"><span class="anchor-link" id="example"></span>Example<a aria-labelledby="heading-example" class="anchor-link-style" href="#example" tabindex="-1"><svg><use xlink:href="#anchor-link-icon" /></svg></a></h2>',{demo:"pages/components/backdrop/SimpleBackdrop.js"},'<h2 id="heading-unstyled"><span class="anchor-link" id="unstyled"></span>Unstyled<a aria-labelledby="heading-unstyled" class="anchor-link-style" href="#unstyled" tabindex="-1"><svg><use xlink:href="#anchor-link-icon" /></svg></a></h2><p>The backdrop also comes with the Base package.\nIt&#39;s ideal for doing heavy customizations and minimizing bundle size.</p>\n<pre><code class="language-js"><span class="token keyword">import</span> BackdropUnstyled <span class="token keyword">from</span> <span class="token string">\'@mui/base/BackdropUnstyled\'</span><span class="token punctuation">;</span>\n</code></pre>\n','<h2 id="heading-api"><span class="anchor-link" id="api"></span>API<a aria-labelledby="heading-api" class="anchor-link-style" href="#api" tabindex="-1"><svg><use xlink:href="#anchor-link-icon" /></svg></a></h2><ul>\n<li><a href="/api/backdrop/"><code>&lt;Backdrop /&gt;</code></a></li>\n<li><a href="/api/backdrop-unstyled/"><code>&lt;BackdropUnstyled /&gt;</code></a></li>\n</ul>\n'],toc:[{text:"Example",level:2,hash:"example",children:[]},{text:"Unstyled",level:2,hash:"unstyled",children:[]},{text:"API",level:2,hash:"api",children:[]}],title:"Backdrop React Component",headers:{title:"Backdrop React Component",components:["Backdrop","BackdropUnstyled"],githubLabel:"component: Backdrop"}},pt:{description:"O componente backdrop (pano de fundo) \xe9 usado para fornecer \xeanfase em um elemento espec\xedfico ou partes dele.",location:"/docs/src/pages/components/backdrop/backdrop-pt.md",rendered:['<svg style="display: none;" xmlns="http://www.w3.org/2000/svg">\n  <symbol id="anchor-link-icon" viewBox="0 0 16 16">\n    <path d="M4 9h1v1H4c-1.5 0-3-1.69-3-3.5S2.55 3 4 3h4c1.45 0 3 1.69 3 3.5 0 1.41-.91 2.72-2 3.25V8.59c.58-.45 1-1.27 1-2.09C10 5.22 8.98 4 8 4H4c-.98 0-2 1.22-2 2.5S3 9 4 9zm9-3h-1v1h1c1 0 2 1.22 2 2.5S13.98 12 13 12H9c-.98 0-2-1.22-2-2.5 0-.83.42-1.64 1-2.09V6.25c-1.09.53-2 1.84-2 3.25C6 11.31 7.55 13 9 13h4c1.45 0 3-1.69 3-3.5S14.5 6 13 6z" />\n  </symbol>\n</svg>','<h1>Backdrop</h1><p class="description">O componente backdrop (pano de fundo) \xe9 usado para fornecer \xeanfase em um elemento espec\xedfico ou partes dele.</p>\n\n<p>O backdrop sinaliza para o usu\xe1rio uma mudan\xe7a de estado dentro do aplicativo e pode ser usado para criar progressos, di\xe1logos e muito mais. Em seu formato mais simples, o componente backdrop ir\xe1 adicionar uma camada escurecida sobre seu aplicativo.</p>\n',{component:"modules/components/ComponentLinkHeader.js"},'<h2 id="heading-example"><span class="anchor-link" id="example"></span>Exemplo<a aria-labelledby="heading-example" class="anchor-link-style" href="#example" tabindex="-1"><svg><use xlink:href="#anchor-link-icon" /></svg></a></h2>',{demo:"pages/components/backdrop/SimpleBackdrop.js"},'<h2 id="heading-unstyled"><span class="anchor-link" id="unstyled"></span>Unstyled<a aria-labelledby="heading-unstyled" class="anchor-link-style" href="#unstyled" tabindex="-1"><svg><use xlink:href="#anchor-link-icon" /></svg></a></h2><p>The backdrop also comes with the Base package. \xc9 ideal para fazer personaliza\xe7\xf5es pesadas e diminuir o tamanho do pacote.</p>\n<pre><code class="language-js"><span class="token keyword">import</span> BackdropUnstyled <span class="token keyword">from</span> <span class="token string">\'@mui/base/BackdropUnstyled\'</span><span class="token punctuation">;</span>\n</code></pre>\n','<h2 id="heading-api"><span class="anchor-link" id="api"></span>API<a aria-labelledby="heading-api" class="anchor-link-style" href="#api" tabindex="-1"><svg><use xlink:href="#anchor-link-icon" /></svg></a></h2><ul>\n<li><a href="/pt/api/backdrop/"><code>&lt;Backdrop /&gt;</code></a></li>\n<li><a href="/pt/api/backdrop-unstyled/"><code>&lt;BackdropUnstyled /&gt;</code></a></li>\n</ul>\n'],toc:[{text:"Exemplo",level:2,hash:"example",children:[]},{text:"Unstyled",level:2,hash:"unstyled",children:[]},{text:"API",level:2,hash:"api",children:[]}],title:"Componente React para Pano de Fundo",headers:{title:"Componente React para Pano de Fundo",components:["Backdrop","BackdropUnstyled"],githubLabel:"component: Backdrop"}},zh:{description:"\u8499\u7248\u7ec4\u4ef6\u7528\u4e8e\u7279\u5b9a\u5143\u7d20\u6216\u5176\u90e8\u5206\u7684\u5f3a\u8c03\u3002",location:"/docs/src/pages/components/backdrop/backdrop-zh.md",rendered:['<svg style="display: none;" xmlns="http://www.w3.org/2000/svg">\n  <symbol id="anchor-link-icon" viewBox="0 0 16 16">\n    <path d="M4 9h1v1H4c-1.5 0-3-1.69-3-3.5S2.55 3 4 3h4c1.45 0 3 1.69 3 3.5 0 1.41-.91 2.72-2 3.25V8.59c.58-.45 1-1.27 1-2.09C10 5.22 8.98 4 8 4H4c-.98 0-2 1.22-2 2.5S3 9 4 9zm9-3h-1v1h1c1 0 2 1.22 2 2.5S13.98 12 13 12H9c-.98 0-2-1.22-2-2.5 0-.83.42-1.64 1-2.09V6.25c-1.09.53-2 1.84-2 3.25C6 11.31 7.55 13 9 13h4c1.45 0 3-1.69 3-3.5S14.5 6 13 6z" />\n  </symbol>\n</svg>','<h1>\u8499\u7248</h1><p class="description">\u8499\u7248\u7ec4\u4ef6\u7528\u4e8e\u7279\u5b9a\u5143\u7d20\u6216\u5176\u90e8\u5206\u7684\u5f3a\u8c03\u3002</p>\n\n<p>\u8499\u7248\u7ec4\u4ef6\u53ef\u4ee5\u7528\u6765\u63d0\u9192\u7528\u6237\u5f53\u524d\u5e94\u7528\u72b6\u6001\u7684\u53d8\u5316\uff0c\u540c\u65f6\u5b83\u4e5f\u53ef\u4ee5\u7528\u6765\u521b\u5efa\u52a0\u8f7d\u906e\u7f69\u5c42\u3001\u5bf9\u8bdd\u6846\u7b49\u7b49\u3002 \u5728\u6700\u7b80\u5355\u7684\u60c5\u51b5\u4e0b\uff0c\u80cc\u666f\u6697\u5316\u7ec4\u4ef6\u5c06\u5728\u60a8\u7684\u5e94\u7528\u7a0b\u5e8f\u4e0a\u6dfb\u52a0\u4e00\u4e2a\u6697\u6de1\u7684\u56fe\u5c42\u3002</p>\n',{component:"modules/components/ComponentLinkHeader.js"},'<h2 id="heading-example"><span class="anchor-link" id="example"></span>\u793a\u4f8b<a aria-labelledby="heading-example" class="anchor-link-style" href="#example" tabindex="-1"><svg><use xlink:href="#anchor-link-icon" /></svg></a></h2>',{demo:"pages/components/backdrop/SimpleBackdrop.js"},'<h2 id="heading-unstyled"><span class="anchor-link" id="unstyled"></span>\u7d20\u989c\u6a21\u5f0f<a aria-labelledby="heading-unstyled" class="anchor-link-style" href="#unstyled" tabindex="-1"><svg><use xlink:href="#anchor-link-icon" /></svg></a></h2><p>The backdrop also comes with the Base package. The backdrop also comes with the unstyled package. It&#39;s ideal for doing heavy customizations and minimizing bundle size.</p>\n<pre><code class="language-js"><span class="token keyword">import</span> BackdropUnstyled <span class="token keyword">from</span> <span class="token string">\'@mui/base/BackdropUnstyled\'</span><span class="token punctuation">;</span>\n</code></pre>\n','<h2 id="heading-api"><span class="anchor-link" id="api"></span>API<a aria-labelledby="heading-api" class="anchor-link-style" href="#api" tabindex="-1"><svg><use xlink:href="#anchor-link-icon" /></svg></a></h2><ul>\n<li><a href="/zh/api/backdrop/"><code>&lt;Backdrop /&gt;</code></a></li>\n<li><a href="/zh/api/backdrop-unstyled/"><code>&lt;BackdropUnstyled /&gt;</code></a></li>\n</ul>\n'],toc:[{text:"\u793a\u4f8b",level:2,hash:"example",children:[]},{text:"\u7d20\u989c\u6a21\u5f0f",level:2,hash:"unstyled",children:[]},{text:"API",level:2,hash:"api",children:[]}],title:"React Backdrop\uff08\u80cc\u666f\u6697\u5316\uff09\u7ec4\u4ef6",headers:{title:"React Backdrop\uff08\u80cc\u666f\u6697\u5316\uff09\u7ec4\u4ef6",components:["Backdrop","BackdropUnstyled"],githubLabel:"\u7ec4\u4ef6\uff1a\u80cc\u666f\u6697\u5316"}}},h={"pages/components/backdrop/SimpleBackdrop.js":{module:"./SimpleBackdrop.js",raw:"import * as React from 'react';\nimport Backdrop from '@mui/material/Backdrop';\nimport CircularProgress from '@mui/material/CircularProgress';\nimport Button from '@mui/material/Button';\n\nexport default function SimpleBackdrop() {\n  const [open, setOpen] = React.useState(false);\n  const handleClose = () => {\n    setOpen(false);\n  };\n  const handleToggle = () => {\n    setOpen(!open);\n  };\n\n  return (\n    <div>\n      <Button onClick={handleToggle}>Show backdrop</Button>\n      <Backdrop\n        sx={{ color: '#fff', zIndex: (theme) => theme.zIndex.drawer + 1 }}\n        open={open}\n        onClick={handleClose}\n      >\n        <CircularProgress color=\"inherit\" />\n      </Backdrop>\n    </div>\n  );\n}\n",jsxPreview:"<Button onClick={handleToggle}>Show backdrop</Button>\n<Backdrop\n  sx={{ color: '#fff', zIndex: (theme) => theme.zIndex.drawer + 1 }}\n  open={open}\n  onClick={handleClose}\n>\n  <CircularProgress color=\"inherit\" />\n</Backdrop>",moduleTS:"./SimpleBackdrop.js",rawTS:"import * as React from 'react';\nimport Backdrop from '@mui/material/Backdrop';\nimport CircularProgress from '@mui/material/CircularProgress';\nimport Button from '@mui/material/Button';\n\nexport default function SimpleBackdrop() {\n  const [open, setOpen] = React.useState(false);\n  const handleClose = () => {\n    setOpen(false);\n  };\n  const handleToggle = () => {\n    setOpen(!open);\n  };\n\n  return (\n    <div>\n      <Button onClick={handleToggle}>Show backdrop</Button>\n      <Backdrop\n        sx={{ color: '#fff', zIndex: (theme) => theme.zIndex.drawer + 1 }}\n        open={open}\n        onClick={handleClose}\n      >\n        <CircularProgress color=\"inherit\" />\n      </Backdrop>\n    </div>\n  );\n}\n"}},f={"./SimpleBackdrop.js":function(){var n=t.useState(!1),e=(0,i.Z)(n,2),o=e[0],r=e[1];return(0,p.jsxs)("div",{children:[(0,p.jsx)(l.Z,{onClick:function(){r(!o)},children:"Show backdrop"}),(0,p.jsx)(s.Z,{sx:{color:"#fff",zIndex:function(n){return n.zIndex.drawer+1}},open:o,onClick:function(){r(!1)},children:a||(a=(0,p.jsx)(c.Z,{color:"inherit"}))})]})}};function m(){return d||(d=(0,p.jsx)(r.Z,{demos:h,docs:u,demoComponents:f}))}},301728:function(n,e,o){(window.__NEXT_P=window.__NEXT_P||[]).push(["/components/backdrop",function(){return o(678105)}])},309318:function(n,e,o){"use strict";function a(n){if(void 0===n)throw new ReferenceError("this hasn't been initialised - super() hasn't been called");return n}o.d(e,{Z:function(){return a}})},962187:function(n,e,o){"use strict";o.d(e,{Z:function(){return u}});var a=o(875499),t=o(128274),r=o(982055);function i(n){return(i=t?r:function(n){return n.__proto__||r(n)})(n)}var s=o(41281),c=o(950093);function l(n){return(l="function"==typeof s&&"symbol"==typeof c?function(n){return typeof n}:function(n){return n&&"function"==typeof s&&n.constructor===s&&n!==s.prototype?"symbol":typeof n})(n)}var p=o(309318);function d(n,e){if(e&&("object"===l(e)||"function"===typeof e))return e;if(void 0!==e)throw new TypeError("Derived constructors may only return object or undefined");return(0,p.Z)(n)}function u(n){var e=function(){if("undefined"===typeof Reflect||!a)return!1;if(a.sham)return!1;if("function"===typeof Proxy)return!0;try{return Boolean.prototype.valueOf.call(a(Boolean,[],(function(){}))),!0}catch(n){return!1}}();return function(){var o,t=i(n);if(e){var r=i(this).constructor;o=a(t,arguments,r)}else o=t.apply(this,arguments);return d(this,o)}}},892362:function(n,e,o){"use strict";o.d(e,{Z:function(){return s}});var a=o(38401),t=o(367394),r=o(128274);function i(n,e){return(i=r||function(n,e){return n.__proto__=e,n})(n,e)}function s(n,e){if("function"!==typeof e&&null!==e)throw new TypeError("Super expression must either be null or a function");n.prototype=a(e&&e.prototype,{constructor:{value:n,writable:!0,configurable:!0}}),t(n,"prototype",{writable:!1}),e&&i(n,e)}}},function(n){n.O(0,[64631,31194,2591,35408,16950,91895,58100,61980,54376,892,2798,89799,61879,47439,74906,50067,67414,90478,30016,94616,49774,92888,40179],(function(){return e=301728,n(n.s=e);var e}));var e=n.O();_N_E=e}]);