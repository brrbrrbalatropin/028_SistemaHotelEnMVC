using System.Configuration;

namespace ProyectoHotel.Logica
{
    public class Conexion
    {
        /// <summary>
        /// Direccion de la base de datos. NO se escribe aqui: se lee del Web.config
        /// (seccion connectionStrings, entrada "ConexionHotel"), para poder cambiarla
        /// sin recompilar el proyecto.
        /// </summary>
        public static string CN = ObtenerCadenaConexion();

        private const string CadenaPorDefecto = "Data Source=.\\SQLEXPRESS;Initial Catalog=DB_HOTEL;Integrated Security=True";

        private static string ObtenerCadenaConexion()
        {
            ConnectionStringSettings configuracion = ConfigurationManager.ConnectionStrings["ConexionHotel"];

            // Si alguien borra o daña la seccion del Web.config, se usa el valor por defecto
            // en vez de dejar caer la aplicacion con un error incomprensible.
            if (configuracion == null || string.IsNullOrWhiteSpace(configuracion.ConnectionString))
                return CadenaPorDefecto;

            return configuracion.ConnectionString;
        }
    }
}
