using ProyectoHotel.Logica;
using ProyectoHotel.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace ProyectoHotel.Controllers
{
    public class LoginController : Controller
    {
        // GET: Login
        public ActionResult Index()
        {
            return View();
        }

        [HttpPost]
        public ActionResult Index(string correo, string clave)
        {

            // La clave se verifica contra el hash guardado; nunca se compara texto contra texto.
            Persona ousuario = PersonaLogica.Instancia.Login(correo, clave);

            if (ousuario == null)
            {
                ViewBag.Error = "Usuario o contraseña no correcta";
                return View();
            }

            Session["Usuario"] = ousuario;

            return RedirectToAction("Index", "Inicio");
        }
    }
}