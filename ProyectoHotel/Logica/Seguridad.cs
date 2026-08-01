using System;
using System.Security.Cryptography;

namespace ProyectoHotel.Logica
{
    /// <summary>
    /// Cifrado de contraseñas con PBKDF2 + salt aleatorio.
    /// El hash es de una sola via: se puede verificar, pero NO se puede volver a la clave original.
    /// Formato guardado en la columna PERSONA.Clave:  iteraciones.saltBase64.hashBase64
    /// </summary>
    public class Seguridad
    {
        private const int Iteraciones = 100000;
        private const int TamanoSalt = 16;
        private const int TamanoHash = 32;

        /// <summary>
        /// Convierte una clave en texto plano al formato hash que se guarda en la base de datos.
        /// </summary>
        public static string Hash(string clave)
        {
            if (string.IsNullOrEmpty(clave))
                return "";

            byte[] salt = new byte[TamanoSalt];
            using (RNGCryptoServiceProvider rng = new RNGCryptoServiceProvider())
            {
                rng.GetBytes(salt);
            }

            byte[] hash = Derivar(clave, salt, Iteraciones);

            return Iteraciones + "." + Convert.ToBase64String(salt) + "." + Convert.ToBase64String(hash);
        }

        /// <summary>
        /// Verifica si una clave en texto plano corresponde al hash guardado.
        /// </summary>
        public static bool Verificar(string clave, string hashGuardado)
        {
            if (string.IsNullOrEmpty(clave) || string.IsNullOrEmpty(hashGuardado))
                return false;

            string[] partes = hashGuardado.Split('.');
            if (partes.Length != 3)
                return false;

            try
            {
                int iteraciones = int.Parse(partes[0]);
                byte[] salt = Convert.FromBase64String(partes[1]);
                byte[] hashEsperado = Convert.FromBase64String(partes[2]);

                byte[] hashCalculado = Derivar(clave, salt, iteraciones);

                return SonIguales(hashCalculado, hashEsperado);
            }
            catch (Exception)
            {
                return false;
            }
        }

        /// <summary>
        /// Indica si un valor guardado ya esta cifrado (util para migrar claves viejas en texto plano).
        /// </summary>
        public static bool EsHash(string valor)
        {
            return !string.IsNullOrEmpty(valor) && valor.Split('.').Length == 3;
        }

        private static byte[] Derivar(string clave, byte[] salt, int iteraciones)
        {
            using (Rfc2898DeriveBytes pbkdf2 = new Rfc2898DeriveBytes(clave, salt, iteraciones, HashAlgorithmName.SHA256))
            {
                return pbkdf2.GetBytes(TamanoHash);
            }
        }

        /// <summary>
        /// Comparacion en tiempo constante: no corta al primer byte distinto para no filtrar
        /// informacion por el tiempo que tarda en responder.
        /// </summary>
        private static bool SonIguales(byte[] a, byte[] b)
        {
            if (a.Length != b.Length)
                return false;

            int diferencia = 0;
            for (int i = 0; i < a.Length; i++)
            {
                diferencia |= a[i] ^ b[i];
            }

            return diferencia == 0;
        }
    }
}
