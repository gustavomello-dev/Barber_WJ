"use strict";

require("dotenv").config();

const readline = require("node:readline");
const { Writable } = require("node:stream");
const argon2 = require("argon2");
const pool = require("../config/database");

let ocultar = false;

const saida = new Writable({
  write(texto, encoding, callback) {
    if (!ocultar) {
      process.stdout.write(texto, encoding);
    }

    callback();
  }
});

const terminal = readline.createInterface({
  input: process.stdin,
  output: saida,
  terminal: true
});

function perguntar(mensagem, secreto = false) {
  return new Promise(resolve => {
    if (secreto) {
      process.stdout.write(mensagem);
      ocultar = true;
    }

    terminal.question(secreto ? "" : mensagem, resposta => {
      ocultar = false;

      if (secreto) {
        process.stdout.write("\n");
      }

      resolve(resposta);
    });
  });
}

async function criarAdmin() {
  try {
    console.log("Cadastro de administrador");
    console.log("Banco de destino:", process.env.DB_HOST);

    const nome = (await perguntar("Nome completo: ")).trim();
    const usuario = (await perguntar("Usuário de acesso: ")).trim();
    const email = (await perguntar("E-mail: ")).trim();
    const senha = await perguntar(
      "Senha (não aparecerá ao digitar): ",
      true
    );
    const confirmacao = await perguntar(
      "Confirme a senha: ",
      true
    );

    if (!nome || !usuario || !email) {
      throw new Error("Preencha nome, usuário e e-mail.");
    }

    if (senha.length < 12) {
      throw new Error("Use uma senha com pelo menos 12 caracteres.");
    }

    if (senha !== confirmacao) {
      throw new Error("As senhas não conferem.");
    }

    const senhaHash = await argon2.hash(senha, {
      type: argon2.argon2id
    });

    const resultado = await pool.query(
      `INSERT INTO public.usuarios
         (nome, usuario, email, senha_hash, perfil, ativo)
       VALUES ($1, $2, $3, $4, 'admin', TRUE)
       RETURNING id, nome, usuario`,
      [nome, usuario, email, senhaHash]
    );

    console.log("\nAdministrador criado com sucesso!");
    console.log("Usuário:", resultado.rows[0].usuario);
  } catch (erro) {
    if (erro.code === "23505") {
      console.error("Esse usuário ou e-mail já está cadastrado.");
    } else {
      console.error("Falha ao cadastrar:", erro.message);
    }

    process.exitCode = 1;
  } finally {
    terminal.close();
    await pool.end();
  }
}

criarAdmin();