const cognitoConfig = {
    UserPoolId: "seu-user-pool-id",
    ClientId: "seu-app-client-id"
};

const userPool = new AmazonCognitoIdentity.CognitoUserPool(cognitoConfig);

document.getElementById("loginButton").addEventListener("click", () => {
    const username = prompt("Digite seu usuário:");
    const password = prompt("Digite sua senha:");

    const authenticationData = {
        Username: username,
        Password: password
    };
    const authenticationDetails = new AmazonCognitoIdentity.AuthenticationDetails(authenticationData);

    const userData = {
        Username: username,
        Pool: userPool
    };
    const cognitoUser = new AmazonCognitoIdentity.CognitoUser(userData);

    cognitoUser.authenticateUser(authenticationDetails, {
        onSuccess: (result) => {
            alert("Login realizado com sucesso!");
            document.getElementById("userInfo").innerText = "Usuário autenticado: " + username;
        },
        onFailure: (err) => {
            alert("Erro ao autenticar: " + err.message);
        }
    });
});
