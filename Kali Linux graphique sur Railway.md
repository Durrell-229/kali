# Kali Linux graphique sur Railway

Ce projet lance **Kali Linux + XFCE** dans un conteneur et expose le bureau via **noVNC**, donc il est utilisable depuis un navigateur sans installer de client VNC.

## Déploiement

1. Crée un nouveau projet sur [Railway](https://railway.app/).
2. Déploie ce dépôt depuis GitHub, ou utilise `railway up` depuis ce dossier.
3. Dans **Variables**, définis au minimum :

   ```text
   VNC_PASSWORD=un-mot-de-passe-fort
   VNC_RESOLUTION=1280x800
   ```

   `PORT` est fourni automatiquement par Railway : ne le fixe pas manuellement.
4. Dans **Settings > Networking**, génère un domaine public Railway.
5. Ouvre `https://TON-DOMAINE/vnc.html`.
6. Clique sur **Connect** et saisis le mot de passe VNC.

Le mot de passe VNC est limité par `x11vnc` aux **8 premiers caractères**. Utilise donc un mot de passe d'au moins 8 caractères, en gardant à l'esprit que seuls les 8 premiers sont vérifiés.

## Test local

```bash
docker build -t kali-railway .
docker run --rm -p 8080:8080 \
  -e VNC_PASSWORD='motdepasse' \
  kali-railway
```

Puis ouvre <http://localhost:8080/vnc.html>.

## Notes importantes

- Railway est un environnement éphémère : les fichiers créés dans le conteneur peuvent être perdus lors d'un redéploiement ou d'un redémarrage. Pour conserver des données, utilise un stockage persistant compatible Railway ou une solution externe.
- Cette image installe `kali-tools-top10`, ce qui rend le build et l'image relativement lourds. Pour une image plus petite, remplace-le par uniquement les paquets Kali dont tu as besoin.
- N'expose pas directement le port VNC `5900` ; noVNC passe par le port HTTP `PORT` de Railway.
- Protège le domaine Railway et n'utilise cet environnement que pour des tests et de l'administration autorisée.
