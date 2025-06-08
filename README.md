# Projeto ILPF - Integração Lavoura-Pecuária-Floresta

## Visão Geral

Este projeto visa [**Descreva o objetivo principal do seu projeto aqui. Ex: "facilitar o planejamento e manejo de sistemas de Integração Lavoura-Pecuária-Floresta através da demarcação de áreas e análise de dados de solo."**]. Ele permite aos usuários desenhar áreas em um mapa, obter informações sobre as características do solo dessas áreas e [**adicione outras funcionalidades principais**].

## Funcionalidades Principais

*   **Desenho de Áreas:** Permite aos usuários desenhar múltiplas áreas poligonais em um mapa.
*   **Ordenação de Vértices:** Organiza automaticamente os vértices dos polígonos para formar uma geometria convexa.
*   **Fechamento de Áreas:** Garante que as áreas desenhadas sejam polígonos fechados.
*   **Obtenção de Dados de Solo:** Busca informações de características do solo (utilizando a API do ISRIC SoilGrids) para o centroide de cada área desenhada.
*   **Desfazer Ação:** Permite ao usuário reverter a última ação de desenho.
*   **Limpar Áreas:** Remove todas as áreas desenhadas.
*   [**Adicione outras funcionalidades relevantes do seu projeto**]

## Tecnologias Utilizadas

*   **Flutter:** Framework para desenvolvimento de interfaces de usuário nativas compiladas.
*   **Dart:** Linguagem de programação utilizada pelo Flutter.
*   **dart_jts (JTS - Java Topology Suite port):** Para operações geométricas como cálculo de Convex Hull.
*   **geodesy:** Para cálculos geodésicos, como encontrar o centroide de um polígono.
*   **http:** Para realizar requisições HTTP à API do SoilGrids.
*   **ISRIC SoilGrids API:** Fonte de dados para informações sobre o solo.

## Como Usar

1.  **Desenhar uma Área:**
    *   Toque no mapa para adicionar pontos e definir os vértices da sua área.
    *   São necessários no mínimo 3 pontos para formar uma área.
2.  **Fechar uma Área:**
    *   Após adicionar os pontos desejados, utilize a função de "Fechar Área".
    *   Isso irá ordenar os pontos, conectar o último ponto ao primeiro e adicionar a área à lista.
3.  **Obter Dados de Solo:**
    *   Após definir uma ou mais áreas, utilize a funcionalidade para buscar os dados de solo.
    *   O sistema irá calcular o centroide de cada área e fazer uma requisição à API do SoilGrids.
4.  **Desfazer:**
    *   Utilize o botão/função "Desfazer" para remover o último ponto adicionado ou a última área fechada.
5.  **Limpar Tudo:**
    *   Utilize a função "Limpar" para remover todas as áreas desenhadas.

## Estrutura do Código (Foco no `AreaController.dart`)

O arquivo `area_controller.dart` é responsável por gerenciar a lógica de criação, manipulação e busca de dados para as áreas geográficas:

*   `areas`: Lista de áreas poligonais já fechadas e processadas.
*   `currentArea`: Lista de pontos da área que está sendo desenhada atualmente.
*   `originalArea`: Armazena a versão original da área antes da ordenação dos vértices (usado para a função "Desfazer").
*   `addPoint(LatLng point)`: Adiciona um novo ponto à `currentArea`.
*   `sort(List<LatLng> areaPoints)`: Utiliza a biblioteca `dart_jts` para calcular o Convex Hull dos pontos, ordenando-os.
*   `closeArea(BuildContext context)`: Valida se a área tem pontos suficientes, ordena os vértices, fecha o polígono e o adiciona à lista `areas`.
*   `resetArea()`: Limpa todas as listas de áreas.
*   `undo()`: Remove o último ponto ou a última área adicionada.
*   `fetchAreaData(BuildContext context)`: Itera sobre todas as áreas fechadas, calcula o centroide de cada uma e busca dados de solo da API do SoilGrids. Inclui lógica de re-tentativa para requisições que falham devido a limites de taxa (status 429).

## Pré-requisitos (Se aplicável para rodar o projeto)

*   Flutter SDK instalado.
*   [**Adicione outros pré-requisitos, como chaves de API, configurações específicas, etc.**]

## Como Contribuir (Opcional)

Se você deseja permitir contribuições, adicione informações aqui:

*   Faça um fork do projeto.
*   Crie uma nova branch (`git checkout -b feature/sua-feature`).
*   Faça commit das suas alterações (`git commit -am 'Adiciona nova feature'`).
*   Faça push para a branch (`git push origin feature/sua-feature`).
*   Abra um Pull Request.

## Licença

[**Especifique a licença do seu projeto aqui. Ex: MIT, Apache 2.0, etc.** Se não tiver certeza, o GitHub oferece opções ao criar o repositório.]

## Contato

[**Seu Nome/Nome da Organização**] - [**Seu E-mail ou link para perfil**]