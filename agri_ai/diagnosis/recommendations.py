# recommendations.py

RECOMMENDATIONS = {
    "healthy": {
        "pathogen": "None (Plant is healthy)",
        "treatment": "No treatment required. The plant is healthy.",
        "prevention": "Continue good agricultural practices: proper watering, spacing, and regular monitoring."
    },

    # New diseases from your list
    "aphids-infestation": {
        "pathogen": "Aphids (various species)",
        "treatment": "Apply neem oil, insecticidal soap, or pyrethrin-based sprays. Introduce natural predators like ladybugs.",
        "prevention": "Maintain plant health, avoid over-fertilizing with nitrogen, and use reflective mulches."
    },

    "bacterial blight disease": {
        "pathogen": "Xanthomonas oryzae pv. oryzae (bacteria)",
        "treatment": "Apply copper-based bactericides. Remove and destroy infected leaves and plants.",
        "prevention": "Use resistant varieties, avoid overhead irrigation, and practice crop rotation."
    },

    "bacterial leaf blight": {
        "pathogen": "Xanthomonas campestris (bacteria)",
        "treatment": "Use copper-based sprays and remove infected plant material. Improve air circulation.",
        "prevention": "Plant resistant varieties and avoid working in wet fields."
    },

    "bacterial-soft-rot": {
        "pathogen": "Pectobacterium carotovorum (bacteria)",
        "treatment": "Remove and destroy affected parts. Apply copper-based sprays if caught early.",
        "prevention": "Avoid wounding plants and ensure good drainage to reduce moisture."
    },

    "black-rot": {
        "pathogen": "Xanthomonas campestris pv. campestris (bacteria)",
        "treatment": "Remove infected plants and apply copper-based bactericides.",
        "prevention": "Use certified disease-free seeds and practice crop rotation."
    },

    "blast disease": {
        "pathogen": "Magnaporthe oryzae (fungus) - Rice Blast",
        "treatment": "Apply fungicides such as tricyclazole or isoprothiolane. Remove infected leaves.",
        "prevention": "Use resistant varieties and avoid excessive nitrogen fertilizer."
    },

    "brown spot": {
        "pathogen": "Cochliobolus miyabeanus (fungus)",
        "treatment": "Apply fungicides and remove infected debris.",
        "prevention": "Use resistant varieties and maintain balanced nutrition."
    },

    "brown spot disease": {
        "pathogen": "Cochliobolus miyabeanus (fungus)",
        "treatment": "Apply appropriate fungicides and improve field sanitation.",
        "prevention": "Avoid water stress and use resistant rice varieties."
    },

    "diamondback-moth": {
        "pathogen": "Plutella xylostella (insect pest)",
        "treatment": "Use Bacillus thuringiensis (Bt) or neem-based insecticides. Introduce natural enemies.",
        "prevention": "Practice crop rotation and use pheromone traps."
    },

    "downy_mildew": {
        "pathogen": "Peronospora spp. or Plasmopara spp. (oomycete)",
        "treatment": "Apply systemic fungicides and remove infected leaves.",
        "prevention": "Improve air circulation and avoid overhead watering."
    },

    "false smut disease": {
        "pathogen": "Ustilaginoidea virens (fungus)",
        "treatment": "Apply fungicides at booting stage. Remove infected panicles.",
        "prevention": "Use resistant varieties and avoid excessive nitrogen."
    },

    "grassy stunt": {
        "pathogen": "Rice grassy stunt virus (virus)",
        "treatment": "No chemical cure. Rogue infected plants and control brown planthopper vectors.",
        "prevention": "Use resistant varieties and manage insect vectors."
    },

    "hispa": {
        "pathogen": "Dicladispa armigera (insect pest)",
        "treatment": "Apply systemic insecticides or neem oil. Hand-pick adults if infestation is low.",
        "prevention": "Maintain field hygiene and use resistant varieties."
    },

    "hoja blanca": {
        "pathogen": "Rice hoja blanca virus (virus)",
        "treatment": "No direct cure. Control the insect vector (planthopper).",
        "prevention": "Use resistant varieties and manage vector population."
    },

    "lead scald": {
        "pathogen": "Microdochium oryzae (fungus)",
        "treatment": "Apply fungicides and improve drainage.",
        "prevention": "Use resistant varieties and avoid excessive humidity."
    },

    "leaf smut": {
        "pathogen": "Entyloma oryzae (fungus)",
        "treatment": "Apply appropriate fungicides and remove infected debris.",
        "prevention": "Use certified seeds and practice field sanitation."
    },

    "sheath blight": {
        "pathogen": "Rhizoctonia solani (fungus)",
        "treatment": "Apply fungicides such as validamycin or carbendazim. Reduce nitrogen fertilizer.",
        "prevention": "Avoid dense planting and ensure good drainage."
    },

    "tungro": {
        "pathogen": "Rice tungro virus (viral complex)",
        "treatment": "No direct cure. Rogue infected plants and control green leafhopper vectors.",
        "prevention": "Use resistant varieties and manage insect vectors early."
    },

    # Keep your original ones (slightly cleaned)
    "angular_leaf_spot": {
        "pathogen": "Pseudocercospora griseola (fungus)",
        "treatment": "Apply copper-based fungicides. Remove infected leaves and avoid overhead watering.",
        "prevention": "Use disease-resistant varieties and practice crop rotation."
    },
    "anthracnose": {
        "pathogen": "Colletotrichum lindemuthianum (fungus)",
        "treatment": "Use fungicides such as chlorothalonil. Remove infected plant debris.",
        "prevention": "Plant certified disease-free seeds and maintain field hygiene."
    },
    "bacterial_spot": {
        "pathogen": "Xanthomonas spp. (bacteria)",
        "treatment": "Apply copper-based sprays. Avoid wet foliage and prune infected areas.",
        "prevention": "Use resistant varieties and ensure proper plant spacing."
    },
    "bean_rust": {
        "pathogen": "Uromyces appendiculatus (fungus)",
        "treatment": "Use fungicides like mancozeb. Remove infected leaves promptly.",
        "prevention": "Practice crop rotation and avoid planting in overly humid areas."
    },
    "blight": {
        "pathogen": "Phytophthora spp. (oomycete / water mold)",
        "treatment": "Apply fungicides and remove infected leaves. Avoid overhead irrigation.",
        "prevention": "Use disease-resistant varieties and ensure good air circulation."
    },
    "common_rust": {
        "pathogen": "Puccinia sorghi (fungus)",
        "treatment": "Use fungicides and remove infected plant material.",
        "prevention": "Plant resistant varieties and maintain crop hygiene."
    },
    "downy_mildew": {
        "pathogen": "Peronospora spp. (oomycete)",
        "treatment": "Use systemic fungicides and remove infected leaves.",
        "prevention": "Improve airflow and avoid excessive moisture."
    },
    "early_blight": {
        "pathogen": "Alternaria solani (fungus)",
        "treatment": "Apply fungicides like chlorothalonil or mancozeb. Remove infected leaves.",
        "prevention": "Rotate crops and avoid overhead watering."
    },
    "gray_leaf_spot": {
        "pathogen": "Cercospora zeae-maydis (fungus)",
        "treatment": "Use fungicides and remove infected foliage.",
        "prevention": "Plant resistant varieties and practice crop rotation."
    },
    "healthy": {
        "pathogen": "None (plant is healthy)",
        "treatment": "No treatment required. Plant is healthy.",
        "prevention": "Maintain good agricultural practices and regular monitoring."
    },
    "late_blight": {
        "pathogen": "Phytophthora infestans (oomycete)",
        "treatment": "Apply copper-based fungicides and remove infected plants.",
        "prevention": "Use certified seeds and avoid excess moisture."
    },
    "leaf_mold": {
        "pathogen": "Passalora fulva (fungus)",
        "treatment": "Use fungicides and improve air circulation.",
        "prevention": "Avoid overhead watering and maintain proper plant spacing."
    },
    "mln_lethal_necrosis": {
        "pathogen": "Maize chlorotic mottle virus + Sugarcane mosaic virus (viral complex)",
        "treatment": "Remove infected plants and avoid cross-contamination.",
        "prevention": "Use resistant varieties and control insect vectors."
    },
    "mosaic_virus": {
        "pathogen": "Various plant viruses",
        "treatment": "No direct cure. Remove infected plants to prevent spread.",
        "prevention": "Use virus-free seeds and control insect vectors."
    },
    "msv_streak_virus": {
        "pathogen": "Maize streak virus (virus)",
        "treatment": "Remove infected plants and control insect vectors.",
        "prevention": "Use resistant varieties and avoid planting in infected areas."
    },
    "septoria_leaf_spot": {
        "pathogen": "Septoria lycopersici (fungus)",
        "treatment": "Apply fungicides and remove infected leaves.",
        "prevention": "Rotate crops and avoid excessive moisture."
    },
    "spider_mite": {
        "pathogen": "Tetranychus urticae (mite – not a pathogen but a pest)",
        "treatment": "Use miticides and increase humidity to reduce mite populations.",
        "prevention": "Monitor crops regularly and remove infested leaves."
    },
    "target_spot": {
        "pathogen": "Corynespora cassiicola (fungus)",
        "treatment": "Apply fungicides and remove infected foliage.",
        "prevention": "Use resistant varieties and practice crop sanitation."
    },
    "yellow_leaf_curl_virus": {
        "pathogen": "Begomovirus (virus complex transmitted by whiteflies)",
        "treatment": "No direct cure. Remove infected plants and control whiteflies.",
        "prevention": "Use resistant varieties and insect control measures."
    }
}