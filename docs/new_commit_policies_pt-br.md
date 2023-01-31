# Políticas de Commits

## Primeiro Caso

Commits são essenciais para acompanhar mudanças e adições ao projeto.

O modo imperativo deve ser usado para mencionar o que foi feito.

Se o commit se refere a um problema simples, faça o commit da seguinte forma:


```git
git commit -m "#IdIssue - Message"
```

### Um caso mais complexo

Devido à sua importância, se o commit se refere a algo mais complexo, use o seguinte modelo para padronização, substituindo o texto dos comentários 'o # não será lido no commit':


```txt
. #Id-of-Issue - Commit title: start with capital letter, objective
# No more than 50 chars, this line has 50                   #
#Skip line

# Body: Explain what and why
# No more than 72 characters (this line has)                                                                             #

#OPTIONAL: If there is, include this line of co-authors of your commit for each contributor.
#Skip 2 lines


# Co-authored-by: name1 <user1@users.noreply.github.com>
# Co-authored-by: name2 <user2@users.noreply.github.com>
#Skip line

```

Para usar o modelo, adicione o arquivo de modelo .gitmessage, sendo no seu diretório de repositório local, na raiz, da seguinte forma:



```git
git config commit.template .gitmessage
```

Em outro caso, você pode simplesmente criar um arquivo .gitmessage e adicionar o corpo do commit sugerido acima. Na próxima vez que você fizer o commit, basta digitar "git commit", e um editor de texto aparecerá (no meu caso, VIM). Preencha todo o corpo do commit com os dados que você deseja descrever.

Por fim, é totalmente possível mudar o texto do corpo do commit.
