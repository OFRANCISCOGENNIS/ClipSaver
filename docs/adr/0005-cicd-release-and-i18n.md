# ADR-0005 — CI/CD, release e internacionalização

- **Status**: aceito
- **Data**: 2026-07-30
- **Fase**: 6

## Contexto

A seção 17 pede pipeline, builds assinados e deploy com aprovação. As
fases 1 a 5 entregaram código com testes, mas nada nunca havia sido
compilado para produção nem publicado. Essa distância é onde moram os
defeitos que só aparecem depois do release.

## Decisões

1. **O CI é dividido por alvo, não por etapa.**
   Um job único pararia na primeira falha e esconderia as outras. Com
   `server`, `app`, `web-build`, `manifests` e `docker` separados, uma
   quebra no Flutter e uma no backend viram duas marcas vermelhas
   independentes — o que reduz o número de rodadas até o verde.

2. **Gate de cobertura por camada, não global.**
   A seção 4.4 pede ≥95% no domínio/aplicação e ≥80% no total. Um número
   só esconde exatamente o caso que este projeto mais teme: uma interface
   bem testada flutuando sobre uma máquina de estados sem teste. Código
   gerado fica fora da conta — `database.g.dart` sozinho moveria o total em
   dezenas de pontos sem dizer nada sobre os testes. E um relatório vazio
   **reprova**: "100% coberto" quando nada rodou é o pior resultado
   possível.

3. **Versão do Flutter e do Node fixadas.**
   `stable` trocaria a toolchain por baixo dos gates sem ninguém pedir. A
   versão fixada é a mesma com que o lockfile e o código gerado foram
   produzidos.

4. **Código gerado é versionado *e* verificado no CI.**
   Os arquivos `.g.dart`, `.freezed.dart` e as traduções geradas estão no
   repositório. Isso é conveniente e é uma armadilha: um checkout com
   geração desatualizada passa no analisador local. O CI regenera e falha
   se houver diferença.

5. **A imagem é construída uma vez e promovida por digest.**
   Reconstruir por ambiente faria produção rodar bytes que staging nunca
   aprovou. Uma tag pode ser movida depois da aprovação; um digest não.

6. **A aprovação manual mora nas regras de proteção do environment.**
   Uma lista de revisores dentro do YAML é editável pelo mesmo pull request
   que quer pular a revisão.

7. **O smoke test pergunta se o build *funciona*, não se subiu.**
   Rollout concluído só significa que os pods iniciaram. O teste checa
   readiness, o catálogo de base legal e — o que importa mais — se o guard
   de SSRF ainda recusa um endereço interno. Um build que sobe com essa
   promessa quebrada é pior do que um build que não sobe.

   O alvo é o endereço de metadados da nuvem, não um host de exemplo: ele é
   recusado antes de qualquer chamada de rede, então o teste é
   determinístico em qualquer ambiente. A primeira versão checava
   `drm.example.com`, que não resolve em lugar nenhum — ela teria reprovado
   todo deploy real.

8. **Liveness não consulta dependência alguma.**
   Se uma queda do Redis reprovasse liveness, o Kubernetes reiniciaria
   todos os pods de uma vez e transformaria uma instabilidade recuperável
   em indisponibilidade. Readiness responde 503 (não 500) para que o pod
   saia do Service em vez de ser reiniciado.

9. **Sem limite de CPU, com limite de memória.**
   Throttlar um event loop transforma pico de latência em timeout. Um
   vazamento de memória, ao contrário, deve matar um pod em vez de deixar o
   nó faminto.

10. **O idioma sai do domínio.**
    `AuthorizationSource.badgeLabel`, `License.displayName` e os `label`
    das enums eram texto de interface morando na camada errada. Agora o
    domínio carrega identidade e comportamento, e o texto vem de extensões
    na camada de apresentação. `License.restrictions` virou
    `List<LicenseRestriction>`: uma obrigação de licença é um fato do
    domínio; como se diz "atribuição obrigatória" não é.

    Os mapeamentos são `switch` exaustivos de propósito — um valor novo na
    enum passa a não compilar até existir texto nos três idiomas, em vez de
    renderizar silenciosamente o nome Dart da constante.

11. **Os sinônimos da busca de configurações são multilíngues de propósito.**
    Quem usa o app em português continua digitando "dark", e quem usa em
    inglês continua lembrando de "escuro". Separar por idioma deixaria a
    busca pior em todos eles. Os nomes de idioma no seletor, pela mesma
    lógica, não são traduzidos: quem procura o próprio idioma procura por
    "English".

12. **Billing verifica recibo no servidor, sempre.**
    Um recibo é entrada controlada pelo atacante. Confiar no que ele diz é
    como um paywall vira sugestão. O cliente entrega um token opaco; quem
    decide é a loja, e o registro de titularidade vive no backend. O
    registro de verificadores **falha fechado**: um provedor que ninguém
    configurou é recusado, não liberado.

13. **A janela de tolerância só vale para assinatura que a loja considera
    renovando.** As lojas repetem uma cobrança falhada por dias, e revogar
    o recurso no instante em que um cartão falha puniria o usuário pelo
    tempo do banco dele. Uma assinatura que o usuário cancelou, porém,
    simplesmente terminou — fingir o contrário seria tomar tempo que ele
    não comprou.

## Consequências

- 121 testes no servidor e 477 no app; cobertura 97,26% no
  domínio/aplicação e 90,78% no total.
- O primeiro run do CI encontrou três defeitos que estavam escondidos
  porque os comandos nunca haviam sido executados: `prisma generate`
  quebrado no Prisma 7, `@prisma/client` em `devDependencies` apesar de ser
  importado em tempo de execução, e um `CMD` apontando para
  `dist/main.js` quando o emit produzia `dist/src/main.js`. Nenhum dos três
  apareceria em teste unitário.
- O que ainda falta, explicitamente:
  - **Assinatura de iOS e macOS**: exige certificado e perfil de
    provisionamento nos secrets. O build de iOS sai sem assinatura, o que
    prova que compila mas não é publicável.
  - **Negociação de idioma no servidor**: as condições de licença e o texto
    educativo de recusa vêm do backend e aparecem em português em qualquer
    locale. O contrato correto é `Accept-Language` na requisição de
    análise.
  - **Deploy da API**: os manifestos e o pipeline existem e são renderizados
    no CI, mas nunca foram aplicados a um cluster — faltam `KUBE_CONFIG` e
    um cluster. O site estático não depende disso.
