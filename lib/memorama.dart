import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MemoramaGame extends StatefulWidget {
  const MemoramaGame({super.key});

  @override
  State<MemoramaGame> createState() => _MemoramaGameState();
}

class _MemoramaGameState extends State<MemoramaGame> {
  final List<Color> _coloresJuego = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.cyan,
    Colors.brown,
    Colors.indigo,
  ];

  final Color _colorInactivo = Colors.grey;

  List<Color> colores = [];

  List<bool> reveladas = [];
  List<bool> emparejadas = [];

  List<int> cartasSeleccionadas = [];
  bool _puedeSeleccionar = true;

  int _movimientos = 0;
  int _coincidencias = 0;

  final FocusNode _nodoFoco = FocusNode();

  @override
  void initState() {
    super.initState();
    inicializar();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nodoFoco.requestFocus();
    });
  }

  @override
  void dispose() {
    _nodoFoco.dispose();
    super.dispose();
  }

  void inicializar() {
    colores = [];

    colores = List.generate(20, (index) {
      int indiceColor = index ~/ 2;
      return _coloresJuego[indiceColor];
    });

    colores.shuffle(Random());

    reveladas = List.generate(20, (index) => false);
    emparejadas = List.generate(20, (index) => false);

    cartasSeleccionadas = [];
    _puedeSeleccionar = true;
    _movimientos = 0;
    _coincidencias = 0;
  }

  void _alTocarCarta(int indice) {

    if (!_puedeSeleccionar || reveladas[indice] || emparejadas[indice]) {
      return;
    }

    setState(() {
      reveladas[indice] = true;
      cartasSeleccionadas.add(indice);
    });

    if (cartasSeleccionadas.length == 2) {
      _puedeSeleccionar = false;
      _movimientos++;

      Future.delayed(const Duration(milliseconds: 500), () {
        _verificarCoincidencia();
      });
    }
  }

  void _verificarCoincidencia() {
    int primeraCarta = cartasSeleccionadas[0];
    int segundaCarta = cartasSeleccionadas[1];

    setState(() {
      if (colores[primeraCarta] == colores[segundaCarta]) {
        emparejadas[primeraCarta] = true;
        emparejadas[segundaCarta] = true;
        _coincidencias++;

        if (_coincidencias == 10) {
          _mostrarDialogoVictoria();
        }
      } else {
        reveladas[primeraCarta] = false;
        reveladas[segundaCarta] = false;
      }

      cartasSeleccionadas = [];
      _puedeSeleccionar = true;
    });
  }

  void _mostrarDialogoVictoria() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¡Felicitaciones!'),
          content: Text('¡Ganaste el juego en $_movimientos movimientos!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  inicializar();
                });
                _nodoFoco.requestFocus();
              },
              child: const Text('Jugar de nuevo'),
            ),
          ],
        );
      },
    );
  }

  void reiniciarJuego() {
    setState(() {
      inicializar();
    });
  }

  void _manejarEventoTeclado(KeyEvent evento) {
    if (evento is KeyDownEvent) {
      if (evento.logicalKey == LogicalKeyboardKey.space) {
        reiniciarJuego();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
        foregroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Memorama'),
            Text(
              'Juarez Ramirez Jose Orlando',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),


      body: KeyboardListener(
        focusNode: _nodoFoco,
        onKeyEvent: _manejarEventoTeclado,
        child: GestureDetector(
          onTap: () {
            _nodoFoco.requestFocus();
          },
          child: Column(
            children: [

              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Text(
                  'Presiona ESPACIO para nuevo juego',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

              Expanded(
                flex: 8,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: List.generate(4, (indiceColumna) {
                            int indiceCarta = 0 * 4 + indiceColumna;
                            return Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: GestureDetector(
                                  onTap: () => _alTocarCarta(indiceCarta),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 100),
                                    decoration: BoxDecoration(
                                      color: reveladas[indiceCarta] || emparejadas[indiceCarta]
                                          ? colores[indiceCarta]
                                          : _colorInactivo,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.black26,
                                        width: 1,
                                      ),
                                      boxShadow: (reveladas[indiceCarta] || emparejadas[indiceCarta])
                                          ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(2, 2),
                                        )
                                      ]
                                          : [],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      Expanded(
                        flex: 2,
                        child: Row(
                          children: List.generate(4, (indiceColumna) {
                            int indiceCarta = 1 * 4 + indiceColumna;
                            return Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: GestureDetector(
                                  onTap: () => _alTocarCarta(indiceCarta),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 100),
                                    decoration: BoxDecoration(
                                      color: reveladas[indiceCarta] || emparejadas[indiceCarta]
                                          ? colores[indiceCarta]
                                          : _colorInactivo,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.black26,
                                        width: 1,
                                      ),
                                      boxShadow: (reveladas[indiceCarta] || emparejadas[indiceCarta])
                                          ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(2, 2),
                                        )
                                      ]
                                          : [],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      Expanded(
                        flex: 2,
                        child: Row(
                          children: List.generate(4, (indiceColumna) {
                            int indiceCarta = 2 * 4 + indiceColumna;
                            return Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: GestureDetector(
                                  onTap: () => _alTocarCarta(indiceCarta),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 100),
                                    decoration: BoxDecoration(
                                      color: reveladas[indiceCarta] || emparejadas[indiceCarta]
                                          ? colores[indiceCarta]
                                          : _colorInactivo,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.black26,
                                        width: 1,
                                      ),
                                      boxShadow: (reveladas[indiceCarta] || emparejadas[indiceCarta])
                                          ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(2, 2),
                                        )
                                      ]
                                          : [],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      Expanded(
                        flex: 2,
                        child: Row(
                          children: List.generate(4, (indiceColumna) {
                            int indiceCarta = 3 * 4 + indiceColumna;
                            return Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: GestureDetector(
                                  onTap: () => _alTocarCarta(indiceCarta),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 100),
                                    decoration: BoxDecoration(
                                      color: reveladas[indiceCarta] || emparejadas[indiceCarta]
                                          ? colores[indiceCarta]
                                          : _colorInactivo,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.black26,
                                        width: 1,
                                      ),
                                      boxShadow: (reveladas[indiceCarta] || emparejadas[indiceCarta])
                                          ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(2, 2),
                                        )
                                      ]
                                          : [],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      Expanded(
                        flex: 2,
                        child: Row(
                          children: List.generate(4, (indiceColumna) {
                            int indiceCarta = 4 * 4 + indiceColumna;
                            return Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: GestureDetector(
                                  onTap: () => _alTocarCarta(indiceCarta),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 100),
                                    decoration: BoxDecoration(
                                      color: reveladas[indiceCarta] || emparejadas[indiceCarta]
                                          ? colores[indiceCarta]
                                          : _colorInactivo,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.black26,
                                        width: 1,
                                      ),
                                      boxShadow: (reveladas[indiceCarta] || emparejadas[indiceCarta])
                                          ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(2, 2),
                                        )
                                      ]
                                          : [],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}