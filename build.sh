# !/bin/bash
git clone --depth 1 --branch v4.2.3 https://github.com/jackyzha0/quartz.git quartz && cd "$_"
npm install
npx quartz build -d ../Content