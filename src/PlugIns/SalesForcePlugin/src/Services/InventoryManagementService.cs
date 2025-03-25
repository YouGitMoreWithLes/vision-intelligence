namespace SalesForcePlugin
{
    public class InventoryManagementService : InventoryManagementService
    {
        public InventoryManagementService()
        {}

        public void CreateInventory()
        {
            Console.WriteLine("Inventory created");
        }

        public void UpdateInventory()
        {
            Console.WriteLine("Inventory updated");
        }

        public void DeleteInventory()
        {
            Console.WriteLine("Inventory deleted");
        }

        public void RetrieveInventory()
        {
            Console.WriteLine("Inventory retrieved");
        }
    }
}