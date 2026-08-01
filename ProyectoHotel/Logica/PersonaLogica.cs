using ProyectoHotel.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Web;

namespace ProyectoHotel.Logica
{
    public class PersonaLogica
    {

        private static PersonaLogica instancia = null;

        public PersonaLogica()
        {

        }

        public static PersonaLogica Instancia
        {
            get
            {
                if (instancia == null)
                {
                    instancia = new PersonaLogica();
                }

                return instancia;
            }
        }

        public List<TipoPersona> ListarTipoPersona()
        {
            List<TipoPersona> Lista = new List<TipoPersona>();
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("select IdTipoPersona,Descripcion from TIPO_PERSONA", oConexion);
                    cmd.CommandType = CommandType.Text;

                    oConexion.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            Lista.Add(new TipoPersona()
                            {
                                IdTipoPersona = Convert.ToInt32(dr["IdTipoPersona"]),
                                Descripcion = dr["Descripcion"].ToString()
                            });
                        }
                    }

                }
                catch (Exception ex)
                {
                    Registro.Error(ex);
                    Lista = new List<TipoPersona>();
                }
            }
            return Lista;
        }

        public bool Registrar(Persona objeto)
        {
            bool respuesta = true;
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("sp_RegistrarPersona", oConexion);
                    cmd.Parameters.AddWithValue("TipoDocumento", objeto.TipoDocumento);
                    cmd.Parameters.AddWithValue("Documento", objeto.Documento);
                    cmd.Parameters.AddWithValue("Nombre", objeto.Nombre);
                    cmd.Parameters.AddWithValue("Apellido", objeto.Apellido);
                    cmd.Parameters.AddWithValue("Correo", objeto.Correo);
                    // La clave NUNCA se guarda en texto plano: se cifra antes de llegar a la base de datos.
                    cmd.Parameters.AddWithValue("Clave", Seguridad.Hash(objeto.Clave));
                    cmd.Parameters.AddWithValue("IdTipoPersona", objeto.oTipoPersona.IdTipoPersona);
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

        public bool Modificar(Persona objeto)
        {
            bool respuesta = true;
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("sp_ModificarPersona", oConexion);
                    cmd.Parameters.AddWithValue("IdPersona", objeto.IdPersona);
                    cmd.Parameters.AddWithValue("TipoDocumento", objeto.TipoDocumento);
                    cmd.Parameters.AddWithValue("Documento", objeto.Documento);
                    cmd.Parameters.AddWithValue("Nombre", objeto.Nombre);
                    cmd.Parameters.AddWithValue("Apellido", objeto.Apellido);
                    cmd.Parameters.AddWithValue("Correo", objeto.Correo);
                    // Si el campo de clave viene vacio se manda vacio y el procedimiento conserva la actual.
                    // Si viene con texto, se cifra y reemplaza la anterior.
                    cmd.Parameters.AddWithValue("Clave", string.IsNullOrWhiteSpace(objeto.Clave) ? "" : Seguridad.Hash(objeto.Clave));
                    cmd.Parameters.AddWithValue("IdTipoPersona", objeto.oTipoPersona.IdTipoPersona);
                    cmd.Parameters.AddWithValue("Estado", objeto.Estado);
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


        /// <summary>
        /// Valida las credenciales de acceso. Devuelve la persona si la clave es correcta, o null si no.
        /// Solo permite entrar a Administradores y Empleados (los Clientes no usan el sistema).
        /// </summary>
        public Persona Login(string correo, string clave)
        {
            Persona oPersona = null;
            string hashGuardado = null;

            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    StringBuilder sb = new StringBuilder();
                    sb.AppendLine("select p.IdPersona,p.TipoDocumento,p.Documento,p.Nombre,p.Apellido,p.Correo,p.Clave,tp.IdTipoPersona,tp.Descripcion, p.Estado from persona p");
                    sb.AppendLine("inner join TIPO_PERSONA tp on tp.IdTipoPersona = p.IdTipoPersona");
                    sb.AppendLine("where p.Correo = @correo and p.IdTipoPersona != 3 and p.Estado = 1");

                    SqlCommand cmd = new SqlCommand(sb.ToString(), oConexion);
                    cmd.Parameters.AddWithValue("@correo", correo);
                    cmd.CommandType = CommandType.Text;

                    oConexion.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            hashGuardado = dr["Clave"].ToString();

                            oPersona = new Persona()
                            {
                                IdPersona = Convert.ToInt32(dr["IdPersona"]),
                                TipoDocumento = dr["TipoDocumento"].ToString(),
                                Documento = dr["Documento"].ToString(),
                                Nombre = dr["Nombre"].ToString(),
                                Apellido = dr["Apellido"].ToString(),
                                Correo = dr["Correo"].ToString(),
                                Clave = "",
                                oTipoPersona = new TipoPersona() { IdTipoPersona = Convert.ToInt32(dr["IdTipoPersona"]), Descripcion = dr["Descripcion"].ToString() },
                                Estado = Convert.ToBoolean(dr["Estado"])
                            };
                        }
                    }
                }
                catch (Exception ex)
                {
                    Registro.Error(ex);
                    oPersona = null;
                }
            }

            if (oPersona == null || !Seguridad.Verificar(clave, hashGuardado))
                return null;

            return oPersona;
        }


        public List<Persona> Listar()
        {
            List<Persona> Lista = new List<Persona>();
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    StringBuilder sb = new StringBuilder();
                    // La clave (aunque este cifrada) NO se consulta aqui: este listado viaja al navegador.
                    sb.AppendLine("select p.IdPersona,p.TipoDocumento,p.Documento,p.Nombre,p.Apellido,p.Correo,tp.IdTipoPersona,tp.Descripcion, p.Estado from persona p");
                    sb.AppendLine("inner join TIPO_PERSONA tp on tp.IdTipoPersona = p.IdTipoPersona");

                    SqlCommand cmd = new SqlCommand(sb.ToString(), oConexion);
                    cmd.CommandType = CommandType.Text;

                    oConexion.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            Lista.Add(new Persona()
                            {
                                IdPersona = Convert.ToInt32(dr["IdPersona"]),
                                TipoDocumento = dr["TipoDocumento"].ToString(),
                                Documento = dr["Documento"].ToString(),
                                Nombre = dr["Nombre"].ToString(),
                                Apellido = dr["Apellido"].ToString(),
                                Correo = dr["Correo"].ToString(),
                                Clave = "",
                                oTipoPersona = new TipoPersona() { IdTipoPersona = Convert.ToInt32(dr["IdTipoPersona"]), Descripcion = dr["Descripcion"].ToString() },
                                Estado = Convert.ToBoolean(dr["Estado"])
                            });
                        }
                    }

                }
                catch (Exception ex)
                {
                    Registro.Error(ex);
                    Lista = new List<Persona>();
                }
            }
            return Lista;
        }

        public bool Eliminar(int id)
        {
            bool respuesta = true;
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("delete from persona where IdPersona = @id", oConexion);
                    cmd.Parameters.AddWithValue("@id", id);
                    cmd.CommandType = CommandType.Text;

                    oConexion.Open();

                    cmd.ExecuteNonQuery();

                    respuesta = true;

                }
                catch (Exception ex)
                {
                    Registro.Error(ex);
                    respuesta = false;
                }

            }

            return respuesta;

        }

    }
}