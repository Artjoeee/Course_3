using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Http;
using System.Security.Claims;

namespace BSTU.Results.Authenticate
{
    public class AuthenticateService
    {
        private readonly List<User> _users = new List<User>
        {
            new User { Login = "reader", Password = "reader123", Role = "READER" },
            new User { Login = "writer", Password = "writer123", Role = "WRITER" }
        };

        public async Task<bool> SignInAsync(HttpContext context, string login, string password)
        {
            var user = _users.FirstOrDefault(u => u.Login == login && u.Password == password);

            if (user == null) 
            { 
                return false; 
            }

            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.Name, user.Login),
                new Claim(ClaimTypes.Role, user.Role)
            };

            var claimsIdentity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);

            var authProperties = new AuthenticationProperties{IsPersistent = true};

            await context.SignInAsync(
                CookieAuthenticationDefaults.AuthenticationScheme,
                new ClaimsPrincipal(claimsIdentity),
                authProperties);

            return true;
        }

        public async Task SignOutAsync(HttpContext context)
        {
            await context.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
        }
    }
}