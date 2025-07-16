using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Linq;

namespace YourNamespace // <-- Replace with your actual namespace
{
    [ApiController]
    [Route("api/[controller]")]
    public class DsrTryController : ControllerBase
    {
        [HttpGet("getProcessTypes")]
        public IActionResult GetProcessTypes()
        {
            var processTypes = new List<(string Code, string Description)>
            {
                ("A", "Add"),
                ("U", "Update")
            };
            return Ok(new { ProcessTypes = processTypes.Select(pt => new { pt.Code, pt.Description }) });
        }
    }
} 