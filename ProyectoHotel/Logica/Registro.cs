using System;
using System.IO;
using System.Runtime.CompilerServices;
using System.Web.Hosting;

namespace ProyectoHotel.Logica
{
    /// <summary>
    /// Deja constancia en un archivo de texto de los errores que la aplicacion atrapa,
    /// para poder saber que fallo sin estar frente al computador.
    ///
    /// Los archivos quedan en:  App_Data\Logs\errores-AAAA-MM-DD.log
    /// (uno por dia). App_Data es una carpeta que el servidor web NO deja descargar
    /// desde el navegador, asi que el contenido no queda expuesto.
    /// </summary>
    public class Registro
    {
        private static readonly object candado = new object();

        /// <summary>
        /// Escribe un error en el archivo del dia.
        /// El nombre del metodo donde ocurrio lo pone el compilador solo: no hay que pasarlo.
        /// </summary>
        public static void Error(Exception ex, [CallerMemberName] string metodo = "")
        {
            Escribir("ERROR", metodo, ex == null ? "(sin detalle)" : ex.ToString());
        }

        /// <summary>
        /// Escribe un mensaje informativo (no es un fallo).
        /// </summary>
        public static void Info(string mensaje, [CallerMemberName] string metodo = "")
        {
            Escribir("INFO", metodo, mensaje);
        }

        private static void Escribir(string nivel, string metodo, string detalle)
        {
            // Si el registro falla (por ejemplo, sin permisos de escritura) NO debe tumbar
            // la aplicacion: es preferible perder el log a dejar al hotel sin sistema.
            try
            {
                string carpeta = ObtenerCarpeta();
                if (carpeta == null)
                    return;

                if (!Directory.Exists(carpeta))
                    Directory.CreateDirectory(carpeta);

                string archivo = Path.Combine(carpeta, "errores-" + DateTime.Now.ToString("yyyy-MM-dd") + ".log");

                string linea =
                    "[" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "] " + nivel + " en " + metodo +
                    Environment.NewLine + detalle +
                    Environment.NewLine + "----------------------------------------" + Environment.NewLine;

                lock (candado)
                {
                    File.AppendAllText(archivo, linea);
                }
            }
            catch (Exception)
            {
                // Intencionalmente vacio: el registro nunca debe propagar errores.
            }
        }

        private static string ObtenerCarpeta()
        {
            try
            {
                // Ruta normal cuando la aplicacion corre en un servidor web (IIS o IIS Express).
                string ruta = HostingEnvironment.MapPath("~/App_Data/Logs");
                if (!string.IsNullOrEmpty(ruta))
                    return ruta;
            }
            catch (Exception)
            {
                // Sigue al plan B.
            }

            try
            {
                // Plan B: al lado de los archivos de la aplicacion.
                return Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "App_Data\\Logs");
            }
            catch (Exception)
            {
                return null;
            }
        }
    }
}
