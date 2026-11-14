import { createClient } from "https://esm.sh/@supabase/supabase-js@2.105.0";

const supabase = createClient(
  "https://tyosxsrkmrgwmefscygc.supabase.co",
  "sb_publishable_f57W8vfsl_9y3lREXuE3TQ_iGbanR4-"
);
const file = location.pathname.split("/").filter(Boolean).pop()?.toLowerCase() || "";
const sectorByFile = {
  "bootcamp.html": "bootcamp",
  "education.html": "education",
  "healthcare.html": "healthcare",
  "factory.html": "factory",
  "real-estate.html": "real-estate",
  "innovation.html": "innovation",
  "agriculture.html": "agriculture"
};
const slug = sectorByFile[file];
const grid = document.querySelector(".projects");
if (!slug || !grid) {
  // The homepage has sector navigation, not a development list.
} else {
  const keepsIllustrativeConcepts = slug === "agriculture";
  if (!keepsIllustrativeConcepts) grid.replaceChildren();

  const palettes = {
    bootcamp: ["#d8ecdc", "#16584d", "#91c9a0"],
    education: ["#e9e8d2", "#355b48", "#bdd68a"],
    healthcare: ["#d9e9e5", "#176b68", "#8bc9bf"],
    factory: ["#e8dfcd", "#6b5136", "#d2a966"],
    "real-estate": ["#e8e2d5", "#375e4c", "#a8c798"],
    innovation: ["#e4def0", "#514277", "#b2a0dd"],
    agriculture: ["#dcebdc", "#315f42", "#9fc58b"]
  };
  const artFor = (name, index) => {
    const [bg, ink, highlight] = palettes[slug];
    const hash = [...name].reduce((n, ch) => (n * 31 + ch.charCodeAt(0)) >>> 0, index + 11);
    const shift = hash % 46;
    const scenes = {
      bootcamp: '<path d="M110 150V91l60-39 60 39v59M139 150v-38h61v38" fill="none" stroke="' + ink + '" stroke-width="10"/><path d="M93 91l77-50 77 50" fill="none" stroke="' + highlight + '" stroke-width="9"/>',
      education: '<path d="M100 151V89h200v62M82 89l118-47 118 47M160 151v-42h80v42" fill="none" stroke="' + ink + '" stroke-width="10"/><path d="M130 103h22m24 0h22m24 0h22" stroke="' + highlight + '" stroke-width="8"/>',
      healthcare: '<path d="M0 122h120l22-28 27 55 30-75 26 48h125" fill="none" stroke="' + ink + '" stroke-width="9" stroke-linecap="round" stroke-linejoin="round"/>',
      factory: '<path d="M98 155V85l48 27V79l48 31V61l73 36v58z" fill="' + ink + '"/><path d="M115 137h22v18h-22zm45 0h22v18h-22zm46 0h22v18h-22z" fill="' + highlight + '"/>',
      "real-estate": '<path d="M103 151V95l48-36 48 36v56M198 151V75l43-31 43 31v76" fill="' + ink + '"/><path d="M123 112h18v20h-18zm42 0h18v20h-18zm54-10h15v18h-15zm32 0h15v18h-15z" fill="' + highlight + '"/>',
      innovation: '<circle cx="170" cy="105" r="47" fill="none" stroke="' + highlight + '" stroke-width="12"/><circle cx="170" cy="105" r="20" fill="' + ink + '"/><path d="M170 35v-20m0 180v-20m70-70h20M80 105h20m120-50 15-15m-130 130 15-15m100 0 15 15" stroke="' + ink + '" stroke-width="8" stroke-linecap="round"/>',
      agriculture: '<path d="M58 149q66-50 132 0t152 0M77 119q62-42 124 0t124 0M104 91q48-29 96 0t96 0" fill="none" stroke="' + ink + '" stroke-width="8"/><path d="M122 154v-42m55 42V94m55 60v-42" stroke="' + highlight + '" stroke-width="8" stroke-linecap="round"/>'
    };
    return '<svg viewBox="0 0 400 190" role="img" xmlns="http://www.w3.org/2000/svg"><rect width="400" height="190" fill="' + bg + '"/><circle cx="' + (310 - shift) + '" cy="42" r="73" fill="' + highlight + '" opacity=".3"/><path d="M0 168q96-28 189-10t211 0v32H0z" fill="' + highlight + '" opacity=".42"/>' + scenes[slug] + '<circle cx="' + (55 + shift) + '" cy="47" r="5" fill="' + ink + '" opacity=".4"/></svg>';
  };
  const formatMoney = amount => new Intl.NumberFormat("en-ZA", {
    style: "currency", currency: "ZAR", maximumFractionDigits: 0
  }).format(Number(amount));
  const emptyState = message => {
    const p = document.createElement("p");
    p.className = "catalog-empty";
    p.setAttribute("role", "status");
    p.textContent = message;
    grid.replaceChildren(p);
  };
  const render = rows => {
    grid.replaceChildren();
    rows.forEach((record, index) => {
      const card = document.createElement("article");
      card.className = "project";
      const art = document.createElement("div");
      art.className = "project-art";
      art.innerHTML = artFor(record.name, index);
      art.firstElementChild.setAttribute("aria-label", record.name + " illustration");
      const body = document.createElement("div");
      body.className = "project-body";
      const title = document.createElement("h2");
      title.textContent = record.name;
      const summary = document.createElement("p");
      summary.textContent = record.summary;
      body.append(title, summary);
      const meta = [];
      if (record.province) meta.push("South Africa · " + record.province);
      if (record.target_amount !== null && record.target_amount !== undefined) {
        meta.push("Target " + formatMoney(record.target_amount));
      }
      if (record.amount_raised !== null && record.amount_raised !== undefined) {
        meta.push("Raised " + formatMoney(record.amount_raised));
      }
      if (meta.length) {
        const info = document.createElement("p");
        info.className = "info";
        info.textContent = meta.join("  ·  ");
        body.append(info);
      }
      card.append(art, body);
      grid.append(card);
    });
  };
  (async () => {
    const { data: sector, error: sectorError } = await supabase
      .from("investment_sectors")
      .select("id")
      .eq("slug", slug)
      .eq("is_active", true)
      .maybeSingle();
    if (sectorError || !sector) {
      if (!keepsIllustrativeConcepts) emptyState("The development catalogue is temporarily unavailable.");
      return;
    }
    const { data, error } = await supabase
      .from("investment_developments")
      .select("name,summary,province,currency,target_amount,amount_raised")
      .eq("sector_id", sector.id)
      .eq("status", "published")
      .order("created_at", { ascending: false });
    if (error) {
      if (!keepsIllustrativeConcepts) emptyState("The development catalogue is temporarily unavailable.");
      return;
    }
    if (data?.length) render(data);
    else if (!keepsIllustrativeConcepts) emptyState("No reviewed developments are published in this sector yet.");
  })();
}
