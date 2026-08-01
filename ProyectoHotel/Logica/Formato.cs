using System;
using System.Globalization;
using System.Text;

namespace ProyectoHotel.Logica
{
    /// <summary>
    /// Convierte a numero y a fecha lo que la persona escribe en pantalla.
    ///
    /// En Colombia los precios se escriben con el punto como separador de miles
    /// (70.000 son setenta mil pesos), pero el navegador envia los valores que el
    /// mismo calcula con punto decimal (70000.5). Esta clase entiende las dos formas
    /// para que nadie tenga que aprenderse un formato especial.
    /// </summary>
    public class Formato
    {
        /// <summary>
        /// Convierte un texto a numero. Si no se puede interpretar, devuelve 0 y lo deja
        /// anotado en el archivo de errores.
        ///
        /// Ejemplos:  "70000" -> 70000     "70.000" -> 70000     "1.250.000" -> 1250000
        ///            "70,50" -> 70.50     "70000,00" -> 70000   "$ 85.000" -> 85000
        /// </summary>
        public static decimal ADecimal(string texto)
        {
            if (string.IsNullOrWhiteSpace(texto))
                return 0m;

            // Deja solo digitos, separadores y el signo negativo (quita "$", espacios, etc).
            StringBuilder limpio = new StringBuilder();
            foreach (char c in texto)
            {
                if (char.IsDigit(c) || c == '.' || c == ',' || c == '-')
                    limpio.Append(c);
            }

            string valor = limpio.ToString();
            if (valor.Length == 0)
            {
                Registro.Info("No se pudo interpretar como numero el valor '" + texto + "'. Se uso 0.");
                return 0m;
            }

            int ultimoSeparador = Math.Max(valor.LastIndexOf('.'), valor.LastIndexOf(','));

            if (ultimoSeparador >= 0)
            {
                int digitosDespues = valor.Length - ultimoSeparador - 1;

                if (digitosDespues == 1 || digitosDespues == 2)
                {
                    // 1 o 2 cifras despues del ultimo separador: son decimales (70,50 / 70000,00).
                    string parteEntera = valor.Substring(0, ultimoSeparador).Replace(".", "").Replace(",", "");
                    string parteDecimal = valor.Substring(ultimoSeparador + 1);
                    valor = parteEntera + "." + parteDecimal;
                }
                else
                {
                    // 3 cifras (o ninguna): es separador de miles (70.000 / 1.250.000).
                    valor = valor.Replace(".", "").Replace(",", "");
                }
            }

            decimal resultado;
            if (decimal.TryParse(valor, NumberStyles.Number, CultureInfo.InvariantCulture, out resultado))
                return resultado;

            Registro.Info("No se pudo interpretar como numero el valor '" + texto + "'. Se uso 0.");
            return 0m;
        }

        /// <summary>
        /// Convierte un texto a fecha esperando el formato dia/mes/ano, que es el que usa
        /// el calendario del sistema. Devuelve null si el texto no es una fecha valida,
        /// para que quien la pidio decida que hacer (no inventa una fecha).
        /// </summary>
        public static DateTime? AFecha(string texto)
        {
            if (string.IsNullOrWhiteSpace(texto))
                return null;

            string[] formatos = { "dd/MM/yyyy", "d/M/yyyy", "dd-MM-yyyy", "d-M-yyyy", "yyyy-MM-dd" };

            DateTime fecha;
            if (DateTime.TryParseExact(texto.Trim(), formatos, CultureInfo.InvariantCulture, DateTimeStyles.None, out fecha))
                return fecha;

            Registro.Info("No se pudo interpretar como fecha el valor '" + texto + "'.");
            return null;
        }
    }
}
