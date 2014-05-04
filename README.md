В данной статье будет показано как при помощи dart и webgl создать простую головомку puzzle.

Готовый пример можно посмотреть [тут](http://cultofdigits.com:10002/puzzle/build/web/puzzle.html), а исходники доступны на [гитхабе](https://github.com/cultofdigits/WebGL_puzzle)

Для начала попробуем определиться с чем нам придется иметь дело, и какие инструменты нам понадобятся. Никакие сторонние библиотеки использоваться не будут, только базовые для работы с матрицами и векторами.
Пазл будет двухмерным, поэтому не придется выводить трехмерные объекты. Для вывода изображения понадобиться работать с текстурами. 

[Создание пазла](#sozdanie-pazla)

[Создание формы деталей головоломки](http://cultofdigits.com/dart-language/sozdanie-golovolomki-na-yazyke-dart-pri-pomoshi-webgl/#sozdanie-unikalnoj-formy-detalej-golovolomki)

[Генерация деталей головоломки в Webgl](http://cultofdigits.com/dart-language/sozdanie-golovolomki-na-yazyke-dart-pri-pomoshi-webgl/#generaciya-detalej-golovolomki-v-webgl)

[Использование текстур в шейдере](http://cultofdigits.com/dart-language/sozdanie-golovolomki-na-yazyke-dart-pri-pomoshi-webgl/#ispolzovanie-tekstur-v-shejdere)

[Выбор деталей](http://cultofdigits.com/dart-language/sozdanie-golovolomki-na-yazyke-dart-pri-pomoshi-webgl/#vybor-detalej)

[Перемещение и поворот деталей](http://cultofdigits.com/dart-language/sozdanie-golovolomki-na-yazyke-dart-pri-pomoshi-webgl/#peremeshenie-i-povorot-detalej)
