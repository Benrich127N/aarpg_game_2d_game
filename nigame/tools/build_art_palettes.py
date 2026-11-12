"""Build the redraw workbook's GPL palettes and vector swatch reference."""
import json
import re
from html import escape
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs/art/palettes"
PALETTES = {
    "street": {
        "title": "Street and buildings",
        "source": "Selected exact colors from scripts/world/District.gd and Interactable.gd.",
        "colors": "60795a:Grass a28d6b:Earth 4d6261:Road 3b443e:Boundary 24382f:Surround 6d8285:Business 769579:Lekki 849f99:Island ce7751:Food stall 7bb3a7:Kiosk a99ad0:Clothes e3bd45:Bus e8ba63:Interaction f1e2bd:Light trim fff0cc:Sign text b26bce:Club entrance",
    },
    "room": {
        "title": "Room interior",
        "source": "Selected exact colors from scripts/world/RoomInterior.gd.",
        "colors": "14231e:Surround 0c1814:Deep shadow 5c412c:Wood shadow 91663f:Board seam ac8052:Wood base b68b5b:Wood warm b18a59:Wood muted bb9160:Wood light 765a3c:Skirting ad8d58:Trim c9b789:Plaster e3cf9e:Wall highlight 506e5d:Rug green c19661:Rug gold 714839:Rug shadow d3bd87:Rug motif 5c4833:Window frame 8db9b0:Day glass 304a5b:Night glass ae7056:Curtain",
    },
    "club": {
        "title": "Club interior",
        "source": "Selected exact colors from scripts/world/ClubInterior.gd.",
        "colors": "101421:Surround 090e19:Speaker black 171724:Booth 201e32:Floor shadow 28253b:Floor base 302c46:Floor alternate 34304b:Walls 56536e:Equipment 775771:Bar d4a778:Counter light 79b4a5:Bottles d3bf8d:Bottle caps 614263:Seat shadow 916185:Seat base aa6d9b:Stools b778ce:Neon 654d80:Dance purple 437f83:Dance teal a76b83:Dance pink 698c80:Exit trim 283d3c:Exit mat",
    },
    "characters": {
        "title": "Characters and wardrobe",
        "source": "Runtime bases from Scenes/Player.gd and WardrobeManager.gd; added suggested outline, skin-shadow and skin-highlight colors. NPC costume ramps are suggestions, not PNG samples.",
        "colors": "242a29:Hair base 4b3229:Hair brown 352f46:Hair plum 70452f:Skin deep base a46d48:Skin medium base d2a07b:Skin light base 4e3025:Suggested deep shadow 875638:Suggested medium shadow e3b58e:Suggested skin highlight 47856c:Green shirt 696da8:Indigo shirt c76c56:Coral shirt d4ab54:Gold shirt 292e32:Dark shoe eee1c2:Cream shoe 8a4c3d:Brown shoe 253143:Suggested trousers 171e2b:Suggested trouser shadow 8a6835:Suggested mustard shadow e3bf70:Suggested mustard light 824b40:Suggested coral shadow e29a7d:Suggested coral light 315b59:Suggested teal shadow 7bb3a7:Suggested teal light 675b83:Suggested lavender shadow c5b6dc:Suggested lavender light 35556d:Suggested blue shadow 88bad1:Suggested blue light",
    },
    "player-masks": {
        "title": "Player source mask colors",
        "source": "Suggested technical colors chosen for the current LayeredCharacter.gd HSV and channel thresholds. Not a sample extraction. Use in source art before runtime wardrobe recoloring.",
        "colors": "116b71:Shirt shadow 18939c:Shirt mid 20bac7:Shirt base 42d9df:Shirt light 181a1b:Hair shadow 222426:Hair base 343739:Hair light 7c2323:Shoe shadow bf3434:Shoe base e95050:Shoe light 70452f:Skin shadow a46d48:Skin base cf9266:Skin light 253143:Trousers 171e2b:Trouser shadow f2e6cf:Eye highlight",
    },
    "ui": {
        "title": "Menus and HUD",
        "source": "Selected exact colors from PixelMenuTheme.gd, GameUI.gd and UI/hud.gd.",
        "colors": "10261d:Track 14291f:Pressed 182a24:HUD panel 182d25:Modal panel 1c3026:Disabled 263f31:Button base 3b563c:Button hover 354c38:Disabled edge 465d43:Track edge 637656:Button edge 7b7955:HUD edge 82927d:Disabled text a99a6a:Panel edge bca05d:Gold base e4c78c:Hover gold f4db9a:Selected marker f5dfa6:Heading efe6cd:Body text fff0cc:Bright text",
    },
}


def build():
    OUT.mkdir(parents=True, exist_ok=True)
    data = {}
    sections = []
    top = 56
    for key, entry in PALETTES.items():
        colors = []
        for match in re.finditer(r"([0-9a-f]{6}):(.+?)(?= [0-9a-f]{6}:|$)", entry["colors"]):
            colors.append({"hex": "#" + match[1].upper(), "name": match[2]})
        data[key] = {"title": entry["title"], "source": entry["source"], "colors": colors}
        lines = ["GIMP Palette", "Name: PH NIGHT - " + entry["title"], "Columns: 4", "# " + entry["source"]]
        for color in colors:
            rgb = tuple(int(color["hex"][i:i+2], 16) for i in (1, 3, 5))
            lines.append(f"{rgb[0]:3} {rgb[1]:3} {rgb[2]:3}\t{color['name']}")
        (OUT / f"ph-night-{key}.gpl").write_text("\n".join(lines) + "\n", encoding="utf-8")
        sections.append(f'<text x="24" y="{top}" class="heading">{escape(entry["title"])}</text>')
        top += 18
        for index, color in enumerate(colors):
            x = 24 + (index % 4) * 252
            y = top + (index // 4) * 58
            sections.append(f'<rect x="{x}" y="{y}" width="44" height="40" fill="{color["hex"]}" stroke="#7b7955"/>')
            sections.append(f'<text x="{x+54}" y="{y+16}" class="label">{escape(color["name"])}</text>')
            sections.append(f'<text x="{x+54}" y="{y+34}" class="hex">{color["hex"]}</text>')
        top += ((len(colors) + 3) // 4) * 58 + 34
    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" width="1040" height="{top}" viewBox="0 0 1040 {top}">
<title>PH NIGHT redraw palettes</title>
<desc>Named swatches for street, room, club, characters, player masks and interface. Exact hex values and provenance are also in palettes.json.</desc>
<style>text {{ font-family: sans-serif; }} .heading {{ fill: #f5dfa6; font-size: 21px; }} .label {{ fill: #efe6cd; font-size: 13px; }} .hex {{ fill: #b9c5b5; font-size: 13px; font-family: monospace; }}</style>
<rect width="1040" height="{top}" fill="#14231e"/>
''' + "\n".join(sections) + "\n</svg>\n"
    (OUT / "palette-preview.svg").write_text(svg, encoding="utf-8")
    (OUT / "palettes.json").write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    print(f"Built {len(data)} palettes, JSON data and SVG preview in {OUT}")


if __name__ == "__main__":
    build()
