# MOVIE ADVISOR

## RUN WITH INTELIJ 

```
mvn clean install

add projogGeneratedClasses/ to classpath

run Main with path to prolog file
```

## RUN WITH JAR

```
mvn clean install

mvn package
```

After that above your project dir, out/ directory will be created, navigate there and run:

```
java -cp projog-core.jar:projogGeneratedClasses/:movie-advisor.jar com.prolog.Main <path to your prolog file>
```