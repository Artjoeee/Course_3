using Microsoft.AspNetCore.Mvc;
using ASPA0011_1.Models;
using ASPA0011_1.Services;

namespace ASPA0011_1.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class QueueController : ControllerBase
    {
        private readonly ChannelManager _manager;

        public QueueController(ChannelManager manager)
        {
            _manager = manager;
        }

        [HttpPost]
        public async Task<IActionResult> Post([FromBody] ChannelCommand cmd)
        {
            if (cmd.Id == null)
            { 
                return BadRequest(); 
            }

            Guid id = Guid.Parse(cmd.Id);

            switch (cmd.Command.ToLower())
            {
                case "enqueue":
                    var res = await _manager.Enqueue(id, cmd.Data ?? "");

                    if (res == null)
                    { 
                        return NotFound(); 
                    }

                    return Ok(new QueueItem { Id = id.ToString(), Data = res });
                case "dequeue":
                    var msg = await _manager.Dequeue(id);

                    if (msg == null)
                    { 
                        return NotFound(); 
                    }

                    return Ok(new QueueItem { Id = id.ToString(), Data = msg });
                case "peek":
                    var peek = await _manager.Peek(id);

                    if (peek == null)
                    { 
                        return NotFound(); 
                    }

                    return Ok(new QueueItem { Id = id.ToString(), Data = peek });
                default:
                    return BadRequest();
            }
        }
    }
}
