***Settings**
Documentation       Aqui teremos todas as palavras chaves fr sutomção dos comportamentos

***Keywords***
Dado que acesso a página principal
    Go To      ${base_url}  

Quando submeto o meu email '${email}'
    Input Text      ${CAMPO_EMAIL}    ${email}    
    click Element   ${BOTAO_ENTRAR}

Então devo ser autenticado
    Wait Until Page Contains Element        ${DIV_DASH} 

Então devo ver a mensagem '${expect_message}'
    Wait Until Element Contains     ${DIV_ALERT}     ${expect_message}

# Cadastro de pratos

Dado que '${produto}' é um dos meus pratos
    Set Test Variable     ${produto}

Quando faço o cadastro desse item
    Wait Until Element Is Visible   ${BOTAO-ADD}   10
    Click Element                   ${BOTAO-ADD}

    Choose File         ${CAMPO_FOTO}      ${EXECDIR}/resources/images/${produto['img']}

    Input Text          ${CAMPO_NOME}         ${produto['nome']}
    Input Text          ${CAMPO_TIPO}         ${produto['tipo']}
    Input Text          ${CAMPO_PRECO}        ${produto['preco']}
    Click Element       ${BOTAO_CADASTRAR}
    
    Sleep       10

Então devo ver este prato no meu dashboard
    Sleep       10
    Wait Until Element Contains     ${DIV_LISTA}      ${produto['nome']}

## kws do cenário receber novo pedido

Dado que '${email_cozinheiro}' é a minha conta de cozinheiro
    Set Test Variable       ${email_cozinheiro}

    &{headers}=          Create Dictionary          Content-Type=application/json   
    &{payload}=          Create Dictionary          email=${email_cozinheiro}            

    Create Session    api         ${api_url}
    ${resp}=          Post Request    api       /sessions       data=${payload}     headers=${headers}
    Status Should Be  200            ${resp}

    ${token_cozinheiro}         Convert To String       ${resp.json()['_id']}
    Set Test Variable           ${token_cozinheiro}

E '${email_cliente}' é o email do meu cliente
    Set Test Variable       ${email_cliente}

    &{headers}=          Create Dictionary          Content-Type=application/json   
    &{payload}=          Create Dictionary          email=${email_cliente}            

    Create Session    api         ${api_url}
    ${resp}=          Post Request    api       /sessions       data=${payload}     headers=${headers}
    Status Should Be  200            ${resp}

    ${token_cliente}         Convert To String       ${resp.json()['_id']}
    Set Test Variable        ${token_cliente}

E que '${produto}' está cadastrado no meu dashboard
    Set Test Variable       ${produto}

    &{payload}=         Create Dictionary       name=${produto}     plate=Tipo      price=17.00

    ${image_file}=      Get Binary File         ${EXECDIR}/resources/images/produto.jpg
    &{files}=            Create Dictionary       thumbnail=${image_file}

    &{headers}=         Create Dictionary       user_id=${token_cozinheiro}  

    Create Session    api         ${api_url}
    ${resp}=          Post Request    api       /products       files=${files}      data=${payload}     headers=${headers}
    Status Should Be  200            ${resp}

    ${produto_id}         Convert To String       ${resp.json()['_id']}
    Set Test Variable     ${produto_id}

        Go To           ${base_url}

    Input Text      ${CAMPO_EMAIL}   ${email_cozinheiro}    
    click Element   ${BOTAO_ENTRAR}

    Wait Until Page Contains Element       ${DIV_DASH}

Quando o cliente solicita o preparo desse prato
    &{headers}=          Create Dictionary          Content-Type=application/json   user_id=${token_cliente}   
    &{payload}=          Create Dictionary          Payment=Dinheiro            

    Create Session    api         ${api_url}
    ${resp}=          Post Request    api       /products/${produto_id}/orders       data=${payload}     headers=${headers}
    Status Should Be  200            ${resp}

Então devo receber um notificação de pedido desse produto
    ${mensagem_esperada}    Convert To String       ${email_cliente} está solicitando o preparo do seguinte prato: ${produto}.
    Wait Until Page Contains    ${mensagem_esperada}        15


E posso aceitar ou rejeitar esse pedido
    Wait Until Page Contains        ACEITAR
    Wait Until Page Contains        REJEITAR    