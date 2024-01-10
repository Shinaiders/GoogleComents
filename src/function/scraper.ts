import express from "express";

import puppeteer from "puppeteer";
import { client } from "../libs/redis.client";

export async function scrapeGoogleReviews(
  req: express.Request,
  res: express.Response
) {
  try {
    const url = req.body.url;

    if (!url) {
      return res.status(400).json({
        error: "url is required",
      });
    }
    const UserSession = await client.get(url);

    if (UserSession) {
      const parsedSession = JSON.parse(UserSession);

      return res.status(200).json(parsedSession);
    } else {
      const browser = await puppeteer.launch({
        args: ["--no-sandbox", "--disable-setuid-sandbox"],
        headless: "new",
      });
      const page = await browser.newPage();
      // Vá para a página inicial do Google
      await page.goto(url);

      const selector =
        "#reviewSort > div > div.gws-localreviews__general-reviews-block";

      await page.waitForSelector(selector, { timeout: 50000 });

      const comments = await page.evaluate(() => {
        // Selecione todos os elementos de comentário na página
        const elements = document.querySelectorAll(
          ".gws-localreviews__google-review"
        );
        return Array.from(elements, (element: any) => {
          // Encontre o elemento que contém o nome do usuário
          const userElement = element.querySelector(".TSUbDb a");
          // Encontre o elemento que contém o texto do comentário
          const commentElement = element.querySelector(".Jtu6Td");
          // Encontre o elemento que contém a imagem do perfil do usuário
          const imageElement = element.querySelector(".lDY1rd");
          // Retorne um objeto que contém o nome do usuário, o texto do comentário e o URL da imagem
          return {
            user: userElement ? userElement.innerText : "",
            comment: commentElement ? commentElement.innerText : "",
            imageUrl: imageElement ? imageElement.src : "",
          };
        });
      });

      await client.set(url, JSON.stringify(comments));
      await client.expire(url, 3600);

      await browser.close();

      return res.status(200).json(comments);
    }
  } catch (error) {
    return res.status(500).json({
      error: error,
    });
  }
}
