import express from "express";
import { scrapeGoogleReviews } from "./function/scraper";

const router = express.Router();

router.get("/", (req, res) => {
  res.send("Tudo está funcionando corretamente!");
});

router.post("/scrapper", scrapeGoogleReviews)

export default router;
