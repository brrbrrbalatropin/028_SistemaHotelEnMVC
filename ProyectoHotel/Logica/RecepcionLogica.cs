using ProyectoHotel.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Web;

namespace ProyectoHotel.Logica
{
    public class RecepcionLogica
    {
        private static RecepcionLogica instancia = null;

        public RecepcionLogica()
        {

        }

        public static RecepcionLogica Instancia
        {
            get
            {
                if (instancia == null)
                {
                    instancia = new RecepcionLogica();
                }

                return instancia;
            }
        }


        public List<Recepcion> Listar()
        {
            List<Recepcion> Lista = new List<Recepcion>();
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {

                    StringBuilder query = new StringBuilder();
                    query.AppendLine("select r.IdRecepcion,p.Nombre,p.Apellido,p.Documento,p.Correo,h.IdHabitacion,h.Numero,h.Detalle,ps.Descripcion[DesPiso],c.Descripcion[DesCategoria],");
                    query.AppendLine("convert(char(10), r.FechaEntrada, 103)[FechaEntrada], convert(char(10), r.FechaSalida, 103)[FechaSalida],r.PrecioInicial,r.Adelanto,r.PrecioRestante,r.Observacion,r.Estado");
                    query.AppendLine("from RECEPCION r");
                    query.AppendLine("inner join persona p on p.IdPersona = r.IdCliente");
                    query.AppendLine("inner join HABITACION h on h.IdHabitacion = r.IdHabitacion");
                    query.AppendLine("inner join PISO ps on ps.IdPiso = h.IdPiso");
                    query.AppendLine("inner join CATEGORIA c on c.IdCategoria = h.IdCategoria");

                    SqlCommand cmd = new SqlCommand(query.ToString(), oConexion);
                    cmd.CommandType = CommandType.Text;

                    oConexion.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            Lista.Add(new Recepcion()
                            {
                                IdRecepcion = Convert.ToInt32(dr["IdRecepcion"]),
                                oCliente = new Persona() {
                                    Nombre = dr["Nombre"].ToString(),
                                    Apellido = dr["Apellido"].ToString(),
                                    Documento = dr["Documento"].ToString(),
                                    Correo = dr["Correo"].ToString(),
                                },
                                oHabitacion = new Habitacion() {
                                    IdHabitacion = Convert.ToInt32(dr["IdHabitacion"]),
                                    Numero = dr["Numero"].ToString(),
                                    Detalle = dr["Detalle"].ToString(),
                                    oPiso = new Piso() { Descripcion = dr["DesPiso"].ToString() },
                                    oCategoria = new Categoria() { Descripcion = dr["DesCategoria"].ToString() }
                                },
                                FechaEntradaTexto = dr["FechaEntrada"].ToString(),
                                FechaSalidaTexto = dr["FechaSalida"].ToString(),
                                // Se leen como numero directamente. Pasarlos por texto y volver a
                                // convertirlos hacia que "70,00" se entendiera como 7000 (x100).
                                PrecioInicial = Convert.ToDecimal(dr["PrecioInicial"]),
                                Adelanto = Convert.ToDecimal(dr["Adelanto"]),
                                PrecioRestante = Convert.ToDecimal(dr["PrecioRestante"]),
                                Observacion = dr["Observacion"].ToString(),
                                Estado = Convert.ToBoolean(dr["Estado"])
                            });
                        }
                    }

                }
                catch (Exception ex)
                {
                    Registro.Error(ex);
                    Lista = new List<Recepcion>();
                }
            }
            return Lista;
        }

        public bool Registrar(Recepcion objeto)
        {
            bool respuesta = true;

            // Si la fecha de salida no se entiende, no se registra nada: es preferible
            // que avise a que guarde una fecha inventada.
            DateTime? fechaSalida = Formato.AFecha(objeto.FechaSalidaTexto);
            if (fechaSalida == null)
            {
                Registro.Info("No se registro la recepcion: la fecha de salida '" + objeto.FechaSalidaTexto + "' no es valida.");
                return false;
            }

            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("sp_registrarRecepcion", oConexion);
                    cmd.Parameters.AddWithValue("IdCliente", objeto.oCliente.IdPersona);
                    cmd.Parameters.AddWithValue("TipoDocumento", objeto.oCliente.TipoDocumento);
                    cmd.Parameters.AddWithValue("Documento", objeto.oCliente.Documento);
                    cmd.Parameters.AddWithValue("Nombre", objeto.oCliente.Nombre);
                    cmd.Parameters.AddWithValue("Apellido", objeto.oCliente.Apellido);
                    cmd.Parameters.AddWithValue("Correo", objeto.oCliente.Correo);
                    cmd.Parameters.AddWithValue("IdHabitacion", objeto.oHabitacion.IdHabitacion);
                    cmd.Parameters.AddWithValue("FechaSalida", fechaSalida.Value);
                    cmd.Parameters.AddWithValue("PrecioInicial", Formato.ADecimal(objeto.PrecioIncialTexto));
                    cmd.Parameters.AddWithValue("Adelanto", Formato.ADecimal(objeto.AdelantoTexto));
                    cmd.Parameters.AddWithValue("PrecioRestante", Formato.ADecimal(objeto.PrecioRestanteTexto));
                    cmd.Parameters.AddWithValue("Observacion", objeto.Observacion);
                    cmd.Parameters.Add("Resultado", SqlDbType.Bit).Direction = ParameterDirection.Output;
                    cmd.CommandType = CommandType.StoredProcedure;

                    oConexion.Open();

                    cmd.ExecuteNonQuery();

                    respuesta = Convert.ToBoolean(cmd.Parameters["Resultado"].Value);

                }
                catch (Exception ex)
                {
                    Registro.Error(ex);
                    respuesta = false;
                }
            }
            return respuesta;
        }

        public bool Cerrar(Recepcion objeto)
        {
            bool respuesta = true;
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {

                oConexion.Open();
                SqlTransaction objTransacion = oConexion.BeginTransaction();

                try
                {
                    
                    StringBuilder query = new StringBuilder();

                    query.AppendLine("update recepcion set FechaSalidaConfirmacion = GETDATE() , TotalPagado = @totapagado , CostoPenalidad = @costopenalidad, Estado = 0");
                    query.AppendLine("where IdRecepcion = @idrecepecion");
                    query.AppendLine("");
                    query.AppendLine("update HABITACION set IdEstadoHabitacion = 3");
                    query.AppendLine("where IdHabitacion = @idhabitacion");

                    SqlCommand cmd = new SqlCommand(query.ToString(), oConexion);
                    cmd.Parameters.AddWithValue("@totapagado", Formato.ADecimal(objeto.TotalPagadoTexto));
                    cmd.Parameters.AddWithValue("@costopenalidad", Formato.ADecimal(objeto.CostoPenalidadTexto));
                    cmd.Parameters.AddWithValue("@idrecepecion", objeto.IdRecepcion);
                    cmd.Parameters.AddWithValue("@idhabitacion", objeto.oHabitacion.IdHabitacion);
                    cmd.CommandType = CommandType.Text;
                    cmd.Transaction = objTransacion;

                    cmd.ExecuteNonQuery();

                    respuesta = true;
                    objTransacion.Commit();

                }
                catch (Exception ex)
                {
                    Registro.Error(ex);
                    objTransacion.Rollback();
                    respuesta = false;
                }

            }

            return respuesta;

        }


    }
}