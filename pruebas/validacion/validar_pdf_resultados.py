"""Comprueba los PDF generados por probar_revision_final.gd (requiere pypdf y pdfplumber)."""
import argparse
from pathlib import Path

import pdfplumber
from pypdf import PdfReader


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("directorio", type=Path)
    args = parser.parse_args()
    nombres = [f"{genero}_{puntaje}.pdf" for genero in ("hombre", "mujer") for puntaje in (8, 28, 40)]
    nombres.append("nombre_largo.pdf")
    for nombre in nombres:
        ruta = args.directorio / nombre
        lector = PdfReader(ruta, strict=True)
        texto = "\n".join(pagina.extract_text() for pagina in lector.pages)
        if nombre != "nombre_largo.pdf":
            assert len(lector.pages) == 1, ruta
            assert "María José Muñoz (revisión)" in texto, ruta
            assert "Atención emocional" in texto and "Reparación emocional" in texto, ruta
            puntaje = int(ruta.stem.split("_")[1])
            assert texto.count(f"{puntaje} / 40") == 3, ruta
            assert f"Puntaje total registrado: {puntaje * 3} / 120" in texto, ruta
        else:
            assert len(lector.pages) > 1, ruta
            for caracter in "ÁÉÍÓÚüñ":
                assert texto.count(caracter) == 140, (ruta, caracter)
        # La frase final debe estar completa, con salto de línea independiente.
        assert "Estos resultados describen tendencias personales y no una calificación." in texto, ruta
        with pdfplumber.open(ruta) as documento:
            for pagina in documento.pages:
                assert pagina.width == 595 and pagina.height == 842, ruta
                for caracter in pagina.chars:
                    assert 40 <= caracter["x0"] < caracter["x1"] <= 555, (ruta, caracter)
                    assert 20 <= caracter["top"] < caracter["bottom"] <= 820, (ruta, caracter)
        print(f"OK: {nombre}, {len(lector.pages)} página(s), acentos, contenido y márgenes")
    print("PDF: 7 documentos correctos")


if __name__ == "__main__":
    main()
