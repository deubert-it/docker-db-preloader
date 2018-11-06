USE test01;

-- --------------------------------------------------------

--
-- Table structure for table `test01table`
--

CREATE TABLE IF NOT EXISTS `test01table` (
`id` int(10) unsigned NOT NULL,
  `a` int(11) NOT NULL,
  `b` int(11) NOT NULL,
  `c` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='test01table';

--
-- Indexes for dumped tables
--

--
-- Indexes for table `test01table`
--
ALTER TABLE `test01table`
 ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `test01table`
--
ALTER TABLE `test01table`
MODIFY `id` int(10) unsigned NOT NULL AUTO_INCREMENT;