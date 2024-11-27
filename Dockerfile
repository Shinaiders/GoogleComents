# Usar a versão 20 do Node.js
FROM node:20

# Instalar o Chrome e todas as dependências necessárias para o Chromium/Puppeteer
RUN apt-get update \
    && apt-get install -y wget gnupg \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
        fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf \
        ca-certificates \
        fonts-liberation \
        libappindicator3-1 \
        libasound2 \
        libatk-bridge2.0-0 \
        libatk1.0-0 \
        libc6 \
        libcairo2 \
        libcups2 \
        libdbus-1-3 \
        libexpat1 \
        libfontconfig1 \
        libgbm1 \
        libgcc1 \
        libglib2.0-0 \
        libgtk-3-0 \
        libnspr4 \
        libnss3 \
        libpango-1.0-0 \
        libpangocairo-1.0-0 \
        libstdc++6 \
        libx11-6 \
        libx11-xcb1 \
        libxcb1 \
        libxcomposite1 \
        libxcursor1 \
        libxdamage1 \
        libxext6 \
        libxfixes3 \
        libxi6 \
        libxrandr2 \
        libxrender1 \
        libxss1 \
        libxtst6 \
        lsb-release \
        wget \
        xdg-utils \
    && rm -rf /var/lib/apt/lists/*

# Instalar o tzdata e configurar o fuso horário
RUN apt-get update && apt-get install -y tzdata
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Definir o diretório de trabalho
WORKDIR /app

# Copiar os arquivos de configuração do projeto
COPY package*.json ./

# Instalar as dependências e o Puppeteer
RUN npm install \
    && npm i puppeteer \
    # Adicionar usuário para evitar a necessidade de --no-sandbox
    && groupadd -r pptruser && useradd -r -g pptruser -G audio,video pptruser \
    && mkdir -p /home/pptruser/Downloads \
    && chown -R pptruser:pptruser /home/pptruser \
    && chown -R pptruser:pptruser /app

# Copiar o restante dos arquivos do projeto
COPY . .

# Executar o Prisma (se necessário)


# Expor a porta 3001
EXPOSE 3001

# Mudar para o usuário não privilegiado
USER pptruser

# Comando para iniciar o aplicativo
CMD ["npm", "run", "start"]
