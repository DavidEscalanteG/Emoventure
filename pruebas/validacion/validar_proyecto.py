"""Validación reproducible de Godot; falla también ante errores impresos por el motor."""
import argparse
from pathlib import Path
import re
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--godot', required=True, help='Ejecutable de Godot 4.5 (consola)')
    parser.add_argument('--project', type=Path, default=Path(__file__).resolve().parents[2])
    parser.add_argument('--smoke', action='store_true', help='Arrancar además las 50 escenas principales')
    parser.add_argument('--logs', type=Path)
    args = parser.parse_args()
    project = args.project.resolve()
    logs = args.logs or Path(tempfile.mkdtemp(prefix='emoventure-validation-'))
    logs.mkdir(parents=True, exist_ok=True)
    failures = []
    marker = re.compile(r'^(?:<{7,}|={7,}|>{7,})(?: |$)', re.MULTILINE)
    for path in project.rglob('*'):
        if any(part.startswith('.') for part in path.relative_to(project).parts):
            continue
        if path.is_file() and path.suffix in {'.gd', '.tscn', '.tres', '.import', '.godot', '.dialogue'}:
            if marker.search(path.read_text(encoding='utf-8-sig')):
                failures.append('Conflicto sin resolver: ' + str(path.relative_to(project)))

    def run(name, options, expected=None):
        command = [args.godot, '--headless', '--path', str(project),
                   '--log-file', str((logs / (name + '-engine.log')).resolve()), *options]
        try:
            result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=180)
            output = result.stdout.decode('utf-8', errors='replace')
            (logs / (name + '.log')).write_text(output, encoding='utf-8')
            diagnostics = [line for line in output.splitlines()
                           if line.startswith(('ERROR:', 'SCRIPT ERROR:', 'WARNING:'))]
            failed = result.returncode != 0 or diagnostics or (expected and expected not in output)
        except subprocess.TimeoutExpired:
            failed = True
            diagnostics = ['Tiempo de espera excedido']
        print(name + ': ' + ('FALLO' if failed else 'OK'), flush=True)
        if failed:
            failures.append(name + ': ' + ' | '.join(dict.fromkeys(diagnostics)))
        return not failed

    if not run('editor', ['--editor', '--import']):
        print('La importación falló; revisar los registros antes de continuar.')
    else:
        run('recursos', ['--script', 'res://pruebas/validacion/validar_recursos.gd'], '0 fallos')
        run('funcionamiento', ['--script', 'res://pruebas/validacion/probar_funcionamiento.gd'], 'FUNCIONAMIENTO: 0 fallos')
        if args.smoke:
            # Componentes y cuestionarios necesitan contexto; los cuestionarios se prueban en el flujo real.
            components = {'EscenaCuestionario.tscn', 'Topo.tscn', 'JugadorBase.tscn', 'Hacha.tscn',
                          'HachaObstaculo.tscn', 'Parca.tscn', 'lanzallamas.tscn', 'estela_particulas.tscn'}
            for scene in sorted((project / 'scenes').rglob('*.tscn')):
                if scene.name in components:
                    continue
                resource_path = 'res://' + scene.relative_to(project).as_posix()
                run(scene.parent.name + '-' + scene.stem,
                    ['--script', 'res://pruebas/validacion/probar_escena.gd', '--', resource_path], 'SMOKE OK:')
    print(f'Registros: {logs}')
    for failure in failures:
        print(failure)
    return 1 if failures else 0


if __name__ == '__main__':
    raise SystemExit(main())
